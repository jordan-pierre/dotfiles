# Neovim IDE layout (LazyVim)

Four-pane IDE aligned with Zed/VS Code shortcuts. **Neovim** owns the file tree and editor; **WezTerm** owns the shell and Claude panes (avoids the broken 4-column toggleterm grid).

## Layout

```
┌─────────────┬──────────────────────────┬──────────────┐
│  neo-tree   │      editor (main)       │   Claude     │
│  (~22%)     │      (inside nvim)       │  WezTerm     │
│  git colors │                          │  run claude  │
├─────────────┼──────────────────────────┤              │
│             │   shell (WezTerm pane)   │              │
│             │   (~15 rows, zsh)        │              │
└─────────────┴──────────────────────────┴──────────────┘
```

- **Left (nvim):** file tree (`neo-tree`), devicons, git-colored names.
- **Center (nvim):** buffers; never auto-closed.
- **Right (WezTerm):** zsh — start `claude` manually.
- **Bottom-left (WezTerm):** project shell under the nvim area only (not under the tree).

On startup the layout opens automatically (dashboard disabled). Skip layout once with `:let g:started_with_layout = 0` before `nvim`. **Reload WezTerm** after config changes (`Cmd+Shift+R`).

## Shortcuts (macOS)

| Shortcut | Action |
|----------|--------|
| **Ctrl+`** | Focus WezTerm shell below nvim (Up returns to nvim) |
| **Cmd+B** | Toggle / focus file tree |
| **Cmd+Shift+B** | Focus WezTerm Claude pane (Left returns to nvim) |
| **Cmd+1 … 9** | Jump to editor buffer slot (MRU order) |
| **Cmd+P** | Quick open **file** (not line numbers) |
| **Cmd+Shift+F** | Search project (ripgrep via snacks) |

**Reliable fallbacks** (always work in WezTerm): `<Space>el` / `er` / `eb` / `fe`, `<Space>p` (files), `<Space>sg` (grep), `<Space>1`–`9` (buffers).
| **Ctrl+h/j/k/l** | Move between nvim windows and WezTerm panes (smart-splits) |

**WezTerm** (outside Neovim): **Cmd+Shift+1–9** switches terminal tabs.

### Leader fallbacks

| Key | Action |
|-----|--------|
| `<leader>el` | Toggle file tree |
| `<leader>er` | Toggle Claude terminal |
| `<leader>eb` | Toggle bottom terminal |
| `<leader>fe` | Focus editor |
| `<leader>f` | LazyVim find (files, grep, buffers, …) |
| `<leader>sg` | Live grep (alias) |
| `<leader>gg` | LazyGit |

### Vim basics

| | |
|-|-|
| `:w` | Save |
| `:q` / `:wq` | Quit / save and quit |
| `:42` or `42G` | Go to line (use instead of Cmd+P for lines) |
| `gg` / `G` | Top / bottom of file |

## Files and search

- **Cmd+P** → `Snacks.picker.files()` — path/name only.
- **Cmd+Shift+F** → live grep; type pattern, Enter to jump.
- Terminal: `rg 'pattern' -g '*.py'`, `rg --files | rg foo`.

## Buffers

Slots **Cmd+1–9** use listed file buffers sorted by recent use. Empty slot does nothing. List buffers: `:buffers` or `<leader>fb`.

## Python

- LSP: **ty** (`vim.g.lazyvim_python_lsp = "ty"`).
- Format on save: **ruff** (fix → format → organize imports), line length **120**.
- Inlay hints enabled on LSP attach.
- Install tools: `:Mason` → `ty`, `ruff`.

## Claude Code

1. **Cmd+Shift+B** → right terminal → run `claude`.
2. Per repo (once): `:CodePreviewInstallClaudeCodeHooks` (needs `jq`).
3. Agent edits show as **inline diffs** (`code-preview.nvim`).
4. `]c` / `[c` — next/prev preview hunk; `<leader>dq` — close preview.
5. Accept/reject in the Claude TUI; `:checkhealth code-preview`, `:CodePreviewStatus`.

`autoread` + `checktime` reload files written by the agent on disk.

## Git

- **gitsigns:** `▎` in gutter for changes.
- **neo-tree:** git status colors on filenames.
- **LazyGit:** `<leader>gg`.

## Themes

macOS light/dark syncs **cyberdream** dark (`default`) and **cyberdream** light. Matches WezTerm cyberdream. Toggle system appearance to test.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Cmd+1–9 switches WezTerm tabs | **Reload WezTerm** (`Cmd+Shift+R`). Tabs are **Cmd+Shift+1–9**; Cmd+1–9 is forwarded to Neovim when `nvim` is focused. |
| Cmd chords not reaching Neovim | Reload WezTerm; use **`<Space>1`–`9`**, **`<Space>el`**, **`<Space>er`**, **`<Space>eb`**, **`<Space>p`**. |
| Layout missing or wrong panes | Run **`:IDELayout`** (resets nvim tree+editor and WezTerm shell+Claude panes). |
| Four columns instead of grid | Old toggleterm layout — reload WezTerm + run `:IDELayout`. Shell/Claude must be WezTerm panes, not nvim windows. |
| Washed-out / wrong light colors | Neovim uses Zed Cyberdream light (`#f5f5f5` editor, `#f2f2f2` sidebar, `#c4b7d7` chrome). Reload WezTerm for matching terminal bg. |
| Panes stacked vertically (tree on top) | Run `:IDELayout` — nvim resets with `only` + left sidebar split. |
| No inline agent diff | Run hook install; restart `claude`; `:CodePreviewStatus` |
| ty / ruff missing | `:Mason` install |
| Plugin errors | `:Lazy`, `:checkhealth` |

## Config map

| Path | Role |
|------|------|
| `lua/config/layout.lua` | Pane toggles, WezTerm multiplex layout, buffer slots |
| `lua/plugins/layout.lua` | smart-splits (WezTerm), neo-tree width, which-key |
| `wezterm/wezterm.lua` | Ctrl+\` / Cmd+Shift+B focus shell & Claude panes |
| `lua/plugins/claude.lua` | code-preview.nvim |
| `lua/plugins/python.lua` | ty, ruff, conform |
| `lua/config/keymaps.lua` | Cmd/Ctrl shortcuts |

More: [LazyVim docs](https://lazyvim.github.io/).
