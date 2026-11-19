# Checkov：从写得通到更合规

## 背景

relay 队要在 EG 环境多落一块存日志的 **Storage Account**（存储账户），这次合入里只加了 `azurerm_storage_account` 的几行。dev 在本地跑过 `terraform validate` 和 plan，都成功；diff 里也只是常规的 tier、复制类型，组里看过觉得可以合。

---

合入流水线在 **IaC 安全扫描** 这一步红了。日志里不是 Terraform 语法错误，而是一串带 `CKV_AZURE_` 前缀的编号，每条都指着同一个资源名和 `.tf` **行号**：嵌套对象允许公网、**TLS** 版本偏低。plan 里从没出现过这些字样。

---

relay 的 dev 愣住：「HCL 不对的话 validate 早挂了，plan 也能出，怎么合不进去？」小 D 把这次改动和扫描报告并排放——失败全落在 **新增的那份 `.tf`**，不是别的队旧配置突然炸出来。要过门禁，得先按行号改资源定义里那几处开关。

---

dev 说合入前从没在笔记本上跑过这道扫描。他盯着报告末尾问小 D：**这些 CKV 编号到底是啥、跟 validate 差在哪？**

## Checkov 与 CKV

流水线那一步跑的是 **Checkov**。它把仓库里的 `**.tf`**（以及同仓里登记的其它 IaC，例如部分 **YAML**）当成「即将变成线上形态」的说明书，在 **不连订阅、不执行 apply** 的前提下，用预制规则逐段对照：这段 Storage 会不会默认露出公网路径、**Key Vault**（密钥保管库）是否缺网络硬边、**TLS** 是否低于团队底线、诊断日志和软删保留是否根本没写进 HCL。扫的是 **意图落地后的风险画像**，不是 Terraform 解析器能不能读懂字段名。

报告里每一行失败都会带一个 **CKV** 编号——**哪条安全或质量规矩没满足** 的短标签。同一个 `CKV_AZURE_59` 在不同合入、不同人写的 Storage 上含义一致，方便在工单、评审和改代码之间对齐，而不必每次争论「这算不算不安全」。规则背后问的是一类固定问题：暴露面过大、加密与传输太弱、可观测性缺口、保留与恢复策略不合基线——**若这份 HCL 明天被 apply，Azure 上会不会长出一块你自己都不愿意背锅的配置。**

这和 **validate** / plan 的分工因此很清楚。validate 与 plan 回答 **写得对不对、计划能不能生成**；Azure 仍会接受许多 **合法但偏危险** 的字段组合，plan 的 diff 里通常只会写 tier、location，不会标红「公网可访问」。relay 的 Storage 就是：**schema 过关，CKV 不过**。Checkov 的意义在于把这类缺口 **前移到合入前**：在 Git 里改几行 HCL，成本远低于资源已经对外提供服务后再封公网、改 **TLS**、补审计日志。

小 D 补了一句：笔记本上要用与 CI 相同的 `**.checkov.yaml**` 跑 `**checkov --config-file**`，同一套 `directory`、同一批规则，Failed 列表才和流水线对得上。按 **CKV、资源、行** 改 `.tf`，是在 **版本库里就把安全与运维约定写死**；扫绿了再 push，门禁才是在重复一次你已经做过的核对，而不是第一次告诉你「线上将要长成什么样」。

## 对比

|          | validate / plan | Checkov（**CKV**）                      |
| -------- | --------------- | ------------------------------------- |
| relay 这次 | 绿               | Failed（公网、TLS 等）                      |
| 合入前      | 照旧              | `checkov --config-file .checkov.yaml` |

## 做法

1. 在 **IaC 仓库根**执行 `checkov --config-file .checkov.yaml`，从 Failed 定位到 `.tf` 行。
2. **改 HCL** 消 Failed（暴露面、TLS、诊断与保留期等写回 Terraform）。
3. 本地扫通后再 push。
4. 可选：`checkov --config-file .checkov.yaml --output json --quiet` 留档。

集中配置里的 `skip-check` 仅是少量已评审例外；主线仍是扫到 Failed 就改代码。示例 `README.md` 里另有 skip 对照，可选。

## 示例

[checkov-workflow](https://github.com/NewbMiao/terraform-on-azure-examples/tree/main/tooling/checkov-workflow/)：`relay_storage.tf` 对应背景里的 Storage 问题。阅读顺序见 `README.md`。

```bash
checkov --config-file tooling/checkov-workflow/.checkov.yaml
```

## 小结

relay：**写得通、plan 绿**，扫描仍可能 **CKV Failed**。弄清 **Checkov / CKV** 与 validate 的分工之后，合入前本地 `checkov --config-file` 与门禁对齐，在改 `.tf` 阶段收口。单靠手跑仍容易忘——目录里 **pre-commit** 一课把同一套扫描挂进 **push** 前自动执行。
