# LSP servers

Language servers used by Eglot, installed locally under this directory.

This directory is git-ignored except for install scripts and package.json
files for each server.

To install servers, run:

```bash
./lsp_servers/install.sh
```

## Adding a new server

Because the whole folder is ignored, git will not show new files as untracked.
After installing a new server, force-add its package files:

```bash
git add -f lsp_servers/<new>/package.json lsp_servers/<new>/package-lock.json
```

Then add it into `eglot-server-programs` in `init.el`.
