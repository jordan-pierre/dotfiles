return {
  -- Default colorscheme: cyberdream when available (matches WezTerm), else tokyonight
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight", -- fallback; cyberdream plugin sets cyberdream after load
    },
  },

  -- Cyberdream: transparent, high-contrast, matches WezTerm cyberdream theme
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, _ = pcall(require, "cyberdream")
      if not ok then
        vim.notify("cyberdream.nvim failed to load; run :Lazy to install.", vim.log.levels.WARN)
        return
      end
      require("cyberdream").setup({
        variant = "default",
        transparent = true,
        italic_comments = false,
        terminal_colors = true,
        borderless_pickers = true,
        extensions = {
          telescope = true,
          notify = true,
          noice = true,
          lualine = true,
          lazy = true,
          indentblankline = true,
          gitsigns = true,
          whichkey = true,
          trouble = true,
        },
      })
      pcall(vim.cmd.colorscheme, "cyberdream")
    end,
  },

  -- Additional colorschemes in picker (<leader>tc)
  {
    "LazyVim/LazyVim",
    opts = {
      colorschemes = {
        { "Everblush/nvim", name = "everblush" },
        { "goolord/alpha-nvim", name = "alpha" },
        { "ray-x/aurora", name = "aurora" },
        { "ribru17/bamboo.nvim", name = "bamboo" },
        { "uloco/bluloco.nvim", name = "bluloco" },
        { "Mofiqul/dracula.nvim", name = "dracula" },
        { "neanias/everforest-nvim", name = "everforest" },
        { "projekt0n/github-nvim-theme", name = "github_dark" },
        { "projekt0n/github-nvim-theme", name = "github_light" },
        { "blazkowolf/gruber-darker.nvim", name = "gruber-darker" },
        { "rktjmp/lush.nvim", name = "lush" },
        { "casedami/neomodern.nvim", name = "neomodern" },
        { "shaunsingh/nord.nvim", name = "nord" },
        { "dgox16/oldworld.nvim", name = "oldworld" },
      },
    },
  },
}
