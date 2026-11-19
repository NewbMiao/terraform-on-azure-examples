# 共享账号：故事开始的地方

## 背景

周二下午，业务团队 **relay** 的 dev 应用挂了。

应用连数据库超时。容器重启了一轮，还是一样。有人去查库——库在跑，防火墙也没动。走内网的那条路断了：数据库的 **Private Endpoint**（私网访问端点）昨晚被人改过，**private DNS** 和现在的 **PE** 对不上号。

---

平台组的小 D 翻开 **Activity Log**（操作审计日志）。

操作者只有一个名字：`shared-deploy@example.com`。没有具体人的 **UPN**（用户登录名），只有这个共享账号邮箱。

---

后来 **relay** 的业务开发认领：昨晚在做 **PE 迁移配置**，用的是这个账号；当时觉得 **不会影响正在跑的 dev**，改完就收工。结果影响来了，日志里仍然只有 `shared-deploy@example.com`。

---

复盘时，老问题也被翻出来。

---

当年人少、平台也忙，排期一满，各业务队就盼着少敲几回「批权限」的门。

---

于是大家要一个能应急的 **共享账号**，平台索性给了一把：**Subscription**（订阅）上的 **Contributor**（内置角色）。**dev**、**prod** 两个订阅里的资源，这把钥匙大体都够得着——换 **PE**、动网络、删东西、起东西，多半都落在这一个邮箱上。

---

人点发布不靠它，**pipeline** 走的是 **service connection**（服务连接），可线那头拽开的，还是订阅级 **Contributor**，范围一样宽。

---

三五个人时还靠群里喊一声，对谁动了哪心里有数；**pulse**、**harbor** 陆续进来以后，谁碰了谁家哪一块，光靠默契就对不上了。

---

日志里说不清是谁，账号却能动很大一片——dev 和 prod 搅在一口锅里。

翻日志的小 D 撂了一句：总不能一直让 `shared-deploy@example.com` 替所有人签字。

---

## 对比：一个账号为什么说不清责任

当年为了让开发不被平台排期卡住，平台给 `shared-deploy@example.com` 开了一把能覆盖整个 Subscription 的钥匙。它能换 PE、删存储，也能跨 dev、prod 操作；出问题时，Activity Log 只能指向这把钥匙，不能回答“哪位成员代表哪个 team 做了这次修改”。

```hcl
data "azuread_service_principal" "shared_deploy" {
  display_name = "shared-deploy" # 对应 shared-deploy@example.com
}

data "azurerm_subscription" "dev" {
  subscription_id = var.dev_subscription_id
}

resource "azurerm_role_assignment" "shared_deploy_dev_subscription" {
  scope                = data.azurerm_subscription.dev.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.shared_deploy.object_id
}
```

**scope** 落在整段 **Subscription** 上，一个 **principal** 盖住好几个 team、**dev** 和 **prod** 两边——日志里只能指到「那一把」，根子在这里。

---

不能再用另一个共享账号顶上去。资源先按 team、按环境归到各队 **RG**，权限跟着这条边来；人进各自的 **SGRP**，只动自己 **Resource Group** 里的东西。

## 对比：让 team 对自己的资源负责

平台把 **relay** 的 ACA、数据库和存储放进 **relay** 的 **RG**，把 **pulse** 的资源放进 **pulse** 的 **RG**。开发需要的权限跟着资源类型和环境收窄；如果某项能力没有合适的内置角色，就只给那一个资源。这样，具体团队负责哪一片资源，先在 Azure 的资源边界上站住。

权限也按 **team** 授：平台把 **RBAC** 绑在队 **SGRP**（**Security Group**，Entra 用户组）上，不给人单独开条子，人跟着组走。有人进来、出去，只动组名单；各队管各队 **RG**，不用再追着每个人改一遍。**Activity Log** 里才有机会同时落到具体的人、具体的资源和哪一队。

**dev**、**prod** 各一张 `dev_resource_groups` / `prod_resource_groups`，放在 `teams.<队>` 里。**relay** 填出来长这样：

```hcl
teams = {
  relay = {
    members = ["owen.relay@example.com"]   # 与 SGRP-RELAY 成员一致，跨队就再进一个队
    dev_resource_groups = {
      relay_dev = {
        subscription_key    = "dev"
        resource_group_name = "RG-RELAY-DEV-SEA"
        roles               = ["Container Apps Contributor", "Key Vault Secrets Officer"]
      }
    }
    prod_resource_groups = {
      relay_prd = {
        subscription_key    = "prod"
        resource_group_name = "RG-RELAY-PRD-SEA"
        roles               = ["Container Apps Operator", "Storage Blob Data Reader"]
      }
    }
  }
}
```

共享 **ACR** 不进 `teams`，单列一张 `shared_resource_access`——一条 ACR，能拉的队各授各的：

```hcl
shared_resource_access = {
  org_acr = {
    subscription_key    = "prod"
    resource_group_name = "RG-EG-HUB-INF"
    resource_name       = "acreg"
    resource_type       = "Microsoft.ContainerRegistry/registries"
    team_grants = {
      relay = { roles = ["Reader"] }
      pulse = { roles = ["Reader"] }
    }
  }
}
```

表里每一行展开成一条授权，只留下 team 的身份，不再把共享账号放在资源边界上：

```hcl
resource "azurerm_role_assignment" "relay_sgrp_dev_aca" {
  scope                = azurerm_resource_group.relay_dev_sea.id
  role_definition_name = "Container Apps Contributor"
  principal_id         = data.azuread_group.sgrp_relay.object_id
}
```

## 前置准备

**负责梳理与准备**：为每个 team 凑齐一张 **「人 + SGRP + RG + 资源 + 大概权限」** 清单，会上或文档里能对上号即可。

| 步骤            | 做什么                                                                                                                                                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **梳理**        | 按 team 列：**谁**（成员 UPN）、**占哪些资源**（ACA、PG、KV…）、落在哪个 **RG** / Subscription；混用、挂错队的标 **待迁**                                                                                                                               |
| **队 SGRP**    | Entra **创建**队 **SGRP**（如 `SGRP-RELAY`），**一队一组**；也可用 Terraform 管 `azuread_group`                                                                                                                                       |
| **team 成员**   | 把成员 **UPN 绑进**对应 SGRP（日后 `teams.<队>.members` 与之一致）；跨队进多个 SGRP，不合成一个大组                                                                                                                                                 |
| **team 的 RG** | **dev / prod** 各定一块 team 的 RG 名；**还没有就先创建**（如 `RG-<队>-DEV-SEA` / `RG-<队>-PRD-SEA`）。此时只确认边界与命名，混用 RG 里的资源记在清单 **待迁** 列                                                                                                 |
| **大概权限**      | 筛 `shared-deploy@example.com` 的 **Activity Log**：共享账号年代各 **resourceId** 上的写操作，归到对应 team / 资源类型，避免漏队、漏类型；再按 **dev / prod** 草拟内置角色（如 dev ACA **Contributor**、prod ACA **Operator**），无内置角色的标 **单资源** + 角色名。先 **大概列表** 即可 |

relay 梳理示例：

| team  | SGRP         | dev RG                                | prod RG                               | 资源摘要              | dev 大概角色                     | prod 大概角色                         |
| ----- | ------------ | ------------------------------------- | ------------------------------------- | ----------------- | ---------------------------- | --------------------------------- |
| relay | `SGRP-RELAY` | `RG-RELAY-DEV-SEA` · `SUB-EG-APP-DEV` | `RG-RELAY-PRD-SEA` · `SUB-EG-APP-PRD` | ACA、PG、KV、Storage | ACA Contributor、PG @ server… | ACA Operator、prod KV 人不读写 secret… |

`subscription_key` 填 `dev` / `prod` 即可；**subscription ID** 由平台订阅表解析。

## 做法

**1. 资源按环境迁入 team 的 RG**  
按前置清单 **待迁** 列，把 ACA、库、存储等 **迁入**本 team 的 **dev** 或 **prod** RG。迁完 **scope** 才与 RBAC 表一致。

**2. 把清单写进 permissions**  
用 **Activity Log** 对照前置「大概权限」，按队填 `teams.<队>`：`members`、**dev** / **prod** 的 `dev_resource_groups` / `prod_resource_groups`；清单里「单资源」进 `resource_access`；共享 **ACR** 进 `shared_resource_access`。一人兼两队 → `members` 写两行，权限并集。

**3. 共享 ACR 上再收一层口**  
几个 team 共用一个 **ACR**，读权限用 `shared_resource_access` 就够用；若还要按 `**relay/`**、`**pulse/**` 这类仓库前缀把 pull/push 隔开，要么给队身份加 **ABAC** 条件，要么用 **scope token**，两条路选一条走到底。条件或 token 的细节，见示例目录 `**README.md`**。

**relay** 定稿示例（`dev_resource_groups` / `prod_resource_groups`）：

| 类型            | dev                         | prod                             | 备注                                                                                                                                                 |
| ------------- | --------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ACA 应用**    | Container Apps Contributor  | Container Apps Operator         | dev 方便改 revision、排障；**prod** 发布走 **pipeline**（服务连接用部署身份），team 成员日常不必占着 **Contributor** 或 **Container Apps Contributor**，**Operator** 看状态、做有限运维即可 |
| **Key Vault** | Key Vault Secrets Officer 等 | 通常不授 team 成员 **prod secret** 读写 | 日常开发不必碰生产 secret；必要初始化由平台运维处理                                                                                                    |
| **Storage**   | Storage Account Contributor | Storage Blob Data Reader        | prod 数据面常只读；写 blob 交给 **pipeline** 或后端身份                                                                                                           |

## 示例与验证

| 目录                                       | 用意                                                                                                                                                   |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`permissions/team-permissions/`](https://github.com/NewbMiao/terraform-on-azure-examples/tree/main/permissions/team-permissions/) | 三队 `**teams**`、relay 单资源、共享 **ACR** 与可选 **scope token**；`dev` / `prod` 各一个 **provider** 别名，和「一订阅一套 provider」的 permissions 心智一致。详阅该目录 `**README.md`** |

```bash
cd permissions/team-permissions
terraform init
terraform plan
```

`terraform plan` 看 diff：**SGRP**、各队 **RG**、角色名是否对得上号；**prod** 这一桌仍是 **Operator** 一类，别把整张订阅又刷成 **Contributor**。

## 思考题

为什么不直接在 **RG** 上给成员授 **RBAC**，非要人进 **SGRP**、权限只绑组？队里就几个人时，这样是不是多此一举？

## 小结

**PE** 改完那一轮，**relay** 的人最怕的还是出事在 **prod**——万一再红一次，会议室里第一句仍是「谁干的」，不能只盯着一个邮箱。

改完之后，**Activity Log** 至少能跟到队和具体人：人走 **SGRP**，东西落在各队自己的 **RG**，**dev** 和 **prod** 各管各的，再也不用一把钥匙替全团顶雷。

可心里得记着：订阅上还挂着整段的 **Contributor**，问「谁」照样兜圈子——授权别比各队肯扛责的那几块 **RG** 还大。
