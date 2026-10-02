#!/usr/bin/env bash
# Usage: ./personalise.sh <FULL_REGISTRATION_NUMBER>   e.g.  ./personalise.sh IT21123456
# Creates ./IE3090_<REG>/ containing the complete personalised repository.
set -euo pipefail
REG="${1:-}"
[ -n "$REG" ] || { echo "usage: $0 <registration number, e.g. IT21123456>"; exit 1; }
NUM=$(echo "$REG" | tr -cd '0-9')
[ ${#NUM} -ge 4 ] || { echo "registration number needs at least 4 digits"; exit 1; }
FIRST4=${NUM:0:4}; L3=${NUM: -3}; LAST4=${NUM: -4}
PORT=$((7000 + 10#$FIRST4)); SID=$(echo "$LAST4" | rev); TOKEN="OPS-$LAST4"; LOG="remoteops_${REG}.log"
HERE="$(cd "$(dirname "$0")" && pwd)"; OUT="$HERE/IE3090_$REG"
mkdir -p "$OUT/docs"
sub() { sed -e "s/@@REGNO@@/$REG/g" -e "s/@@NUM@@/$NUM/g" -e "s/@@FIRST4@@/$FIRST4/g" -e "s/@@LAST4@@/$LAST4/g" \
            -e "s/@@L3@@/$L3/g" -e "s/@@PORT@@/$PORT/g" -e "s/@@SID@@/$SID/g" -e "s/@@TOKEN@@/$TOKEN/g" -e "s/@@LOGFILE@@/$LOG/g" "$1"; }
T="$HERE/templates"
sub $T/agent.c.tmpl      > "$OUT/agent_$L3.c"
sub $T/controller.c.tmpl > "$OUT/controller_$L3.c"
sub $T/Makefile.tmpl     > "$OUT/Makefile_$L3"
sub $T/test.sh.tmpl      > "$OUT/test.sh"; chmod +x "$OUT/test.sh"
sub $T/README.md.tmpl    > "$OUT/README.md"
sub $T/REPORT.md.tmpl    > "$OUT/docs/Implementation_Report_DRAFT.md"
sub $T/DESIGN_DIARY.md.tmpl > "$OUT/docs/DESIGN_DIARY.md"
sub $T/PROMPT_LOG.md.tmpl   > "$OUT/docs/PROMPT_LOG.md"
sub $T/REFLECTION_GUIDE.md.tmpl > "$OUT/docs/REFLECTION_GUIDE.md"
printf 'agent_%s\ncontroller_%s\nagentfiles/\n*.log\nagent_stdout.txt\ndownloaded_*\n*.part*\n' "$L3" "$L3" > "$OUT/.gitignore"
cat <<MSG
Created $OUT
  registration : $REG      port : $PORT      SID : $SID      token : $TOKEN
  files        : agent_$L3.c  controller_$L3.c  Makefile_$L3  log : $LOG
Next: cd "$OUT" && ./test.sh
MSG
