return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      -- prepend_args merges with conform's defaults; overriding `args` drops the subcommand.
      local ruff_120 = { "--config", "line-length=120" }
      opts.formatters.ruff_format = vim.tbl_extend("force", opts.formatters.ruff_format or {}, {
        prepend_args = ruff_120,
      })
      opts.formatters.ruff_fix = vim.tbl_extend("force", opts.formatters.ruff_fix or {}, {
        prepend_args = ruff_120,
      })
      opts.formatters.ruff_organize_imports = vim.tbl_extend("force", opts.formatters.ruff_organize_imports or {}, {
        prepend_args = ruff_120,
      })
      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      })
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false },
        basedpyright = { enabled = false },
        ruff = {
          init_options = {
            settings = {
              lineLength = 120,
            },
          },
        },
        ty = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ty",
        "ruff",
        "stylua",
      })
      return opts
    end,
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ide_inlay_hints", { clear = true }),
        callback = function(args)
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end,
      })
    end,
  },
}
