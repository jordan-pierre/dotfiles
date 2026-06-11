return {
  {
    "Cannon07/code-preview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "CodePreview",
      "CodePreviewStatus",
      "CodePreviewInstallClaudeCodeHooks",
      "CodePreviewUninstallClaudeCodeHooks",
      "CodePreviewCloseDiff",
    },
    opts = {
      diff = {
        layout = "inline",
      },
      neo_tree = {
        enabled = true,
      },
      keys = {
        close_all = "<leader>dq",
      },
    },
    keys = {
      -- <leader>cp is taken by markdown-preview (from lang.markdown extra); use cd for "code diff"
      { "<leader>cd", "<cmd>CodePreviewStatus<cr>", desc = "Code preview (agent diff)" },
      { "<leader>ch", "<cmd>CodePreviewInstallClaudeCodeHooks<cr>", desc = "Install Claude Code hooks" },
      { "<leader>dq", "<Plug>(CodePreviewCloseAll)", desc = "Close code preview diff" },
    },
  },
}
