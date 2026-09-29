#!/usr/bin/env bash
# Independent reimplementation of one problem, for /crosscheck to compare against.
#
# Usage: scripts/crosscheck.sh HWn pK
#
# Two modes:
#
#   Teammate (default, XCHECK_MODEL unset)
#     Builds a packet in HWn/crosscheck/pK/packet/: the spec PDF, rng-notes.md and
#     BRIEF.md (the checker prompt). A teammate who has not seen this problem's
#     code or notes.md implements it from the packet alone and puts
#     results.json and checker-notes.md (and their .py) in HWn/crosscheck/pK/.
#     Exit 0 if those results are already there, 3 if the packet is waiting.
#
#   Model (XCHECK_MODEL=opus, sonnet, ...)
#     Copies only the PDF and rng-notes.md into a fresh directory outside the repo
#     and runs `claude -p` there in an OS sandbox that cannot read this repo, so
#     none of its CLAUDE.md, skills, code or notes.md decisions are visible.
#     Results land in HWn/crosscheck/pK/. Needs macOS or Linux for the sandbox.
#
# Env: XCHECK_MODEL (default unset = teammate mode), XCHECK_BASE (model mode's
# run directory, default /tmp/mth9821-xcheck).
set -euo pipefail

if [[ $# -ne 2 || ! $1 =~ ^HW[0-9]+$ || ! $2 =~ ^p[0-9]+$ ]]; then
    echo "usage: $0 HWn pK   (e.g. $0 HW1 p2)" >&2
    exit 2
fi
HW=$1
PK=$2
K=${PK#p}

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SKILL_DIR=$ROOT/.claude/skills/crosscheck
DEST=$ROOT/$HW/crosscheck/$PK
MODEL=${XCHECK_MODEL:-}

shopt -s nullglob
pdfs=("$ROOT/$HW/spec/"*.pdf)
if [[ ${#pdfs[@]} -ne 1 ]]; then
    echo "error: expected exactly one PDF in $HW/spec/, found ${#pdfs[@]}" >&2
    exit 1
fi
PDF=${pdfs[0]}

fill_prompt() {  # $1 = how to run Python
    sed -e "s|{{PROBLEM}}|$K|g" \
        -e "s|{{PDF}}|$(basename "$PDF")|g" \
        -e "s|{{PYTHON}}|$1|g" \
        "$SKILL_DIR/checker-prompt.md"
}

# ---------------------------------------------------------------- teammate mode
if [[ -z $MODEL ]]; then
    if [[ -f $DEST/results.json && -f $DEST/checker-notes.md ]]; then
        echo "teammate results found in $HW/crosscheck/$PK/"
        ls "$DEST"
        exit 0
    fi
    PACKET=$DEST/packet
    mkdir -p "$PACKET"
    cp "$PDF" "$PACKET/"
    cp "$SKILL_DIR/rng-notes.md" "$PACKET/"
    {
        echo "# Crosscheck brief: $HW problem $K"
        echo
        echo "You are the independent checker for this problem. Until you have finished,"
        echo "don't look at the team's code, notebook or notes.md for $HW. Your reading"
        echo "of the PDF is the point of the check. Work in a copy of this folder."
        echo
        echo "When you're done, put results.json, checker-notes.md and your .py file in"
        echo "$HW/crosscheck/$PK/ (the folder above this packet)."
        echo
        echo "---"
        echo
        fill_prompt "python3"
    } > "$PACKET/BRIEF.md"
    echo "teammate mode: packet ready in $HW/crosscheck/$PK/packet/"
    ls "$PACKET"
    echo
    echo "Send the packet to a teammate who hasn't seen this problem's code or notes.md."
    echo "They put results.json and checker-notes.md in $HW/crosscheck/$PK/;"
    echo "then run /crosscheck $HW $PK again."
    echo "(To use a model instead: XCHECK_MODEL=opus $0 $HW $PK)"
    exit 3
fi

# ------------------------------------------------------------------- model mode
BASE=${XCHECK_BASE:-/tmp/mth9821-xcheck}

# A NumPy/SciPy venv shared across runs, outside the repo, so the checker
# can't import the mth9821 package.
VENV=$BASE/.venv
if [[ ! -x $VENV/bin/python ]]; then
    echo "creating checker venv at $VENV"
    mkdir -p "$BASE"
    PY=$(command -v python3.14 || command -v python3.13 || command -v python3.12 || command -v python3)
    "$PY" -m venv "$VENV"
    "$VENV/bin/pip" install -q numpy scipy
fi

RUN=$BASE/$HW-$PK-$(date +%Y%m%d-%H%M%S)
LOG=$RUN.log   # outside the run dir so the checker never sees it
mkdir -p "$RUN"
cp "$PDF" "$RUN/"
cp "$SKILL_DIR/rng-notes.md" "$RUN/"

PROMPT=$(fill_prompt "$VENV/bin/python")

# Isolation:
#   --safe-mode                     no CLAUDE.md, skills, plugins, hooks, MCP, or auto memory
#   --setting-sources project,local skip ~/.claude/settings.json allow rules (the run dir has no project settings)
#   --permission-mode dontAsk       deny anything not allowed below
#   deny Read/Edit on the repo      blocks Claude's own file tools
#   sandbox, denyRead on the repo   OS-level block for Bash and Python;
#                                   writes confined to the run dir; no unsandboxed retry
SETTINGS=$(cat <<JSON
{"permissions": {"deny": ["Read(/$ROOT/**)", "Edit(/$ROOT/**)"]},
 "sandbox": {"enabled": true, "failIfUnavailable": true, "allowUnsandboxedCommands": false,
             "filesystem": {"denyRead": ["$ROOT"]}}}
JSON
)
echo "running checker in $RUN (model: $MODEL)"
cd "$RUN"
env -u CLAUDECODE claude -p "$PROMPT" \
    --model "$MODEL" \
    --safe-mode \
    --setting-sources project,local \
    --permission-mode dontAsk \
    --tools "Read,Write,Edit,Bash" \
    --allowedTools "Read(./**)" "Edit(./**)" \
                   "Bash($VENV/bin/python *)" "Bash(python *)" "Bash(python3 *)" "Bash(ls *)" \
    --settings "$SETTINGS" \
    --no-session-persistence \
    > "$LOG" 2>&1 || {
        echo "error: claude exited with status $?; see $LOG" >&2
        exit 1
    }

for f in results.json checker-notes.md; do
    if [[ ! -f $RUN/$f ]]; then
        echo "error: checker did not write $f; see $LOG" >&2
        exit 1
    fi
done

mkdir -p "$DEST"
cp "$RUN/results.json" "$RUN/checker-notes.md" "$DEST/"
cp "$LOG" "$DEST/claude-output.txt"
for f in "$RUN"/*.py; do cp "$f" "$DEST/"; done

echo "run dir: $RUN"
echo "copied to: $HW/crosscheck/$PK/"
ls "$DEST"
