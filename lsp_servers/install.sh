#!/usr/bin/env bash
#
# Install the npm-based LSP servers used by Eglot.

set -euo pipefail

cd "$(dirname "$0")"

# npm-managed servers (each has package.json + package-lock.json here):
#   python  -> pyright
#   ts      -> typescript, typescript-language-server
#   bash    -> bash-language-server
#   volar   -> @volar/vue-language-server, typescript
#   html    -> vscode-langservers-extracted (vscode-html-language-server)
#   jsonls  -> vscode-langservers-extracted (vscode-json-language-server)
servers=(python ts bash volar html jsonls)

for d in "${servers[@]}"; do
  echo ">>> installing $d"
  (cd "$d" && npm ci)
done
