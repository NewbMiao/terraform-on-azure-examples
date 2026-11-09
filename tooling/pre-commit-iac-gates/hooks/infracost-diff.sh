#!/bin/sh
set -eu

report_dir=".reports"
current_report="${report_dir}/infracost-current.json"
previous_report="${report_dir}/infracost-previous.json"
diff_report="${report_dir}/infracost-diff.txt"
temp_dir="${TMPDIR:-/tmp}"
next_report="$(mktemp "${temp_dir%/}/infracost-current.XXXXXX")"
next_diff="$(mktemp "${temp_dir%/}/infracost-diff.XXXXXX")"

trap 'rm -f "${next_report}" "${next_diff}"' 0 HUP INT TERM

mkdir -p "${report_dir}"

infracost scan . --json > "${next_report}"

if [ -s "${current_report}" ]; then
  cp "${current_report}" "${previous_report}"
else
  cp "${next_report}" "${previous_report}"
fi

infracost diff . --compare-to "${previous_report}" > "${next_diff}"

mv "${next_report}" "${current_report}"
mv "${next_diff}" "${diff_report}"

cat "${diff_report}"

printf '%s\n' \
  "Infracost current:  ${current_report}" \
  "Infracost previous: ${previous_report}" \
  "Infracost diff:     ${diff_report}"
