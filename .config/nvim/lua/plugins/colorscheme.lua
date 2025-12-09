return {
  -- Set default colorscheme to everblush
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everblush",
    },
  },

  -- Configure everblush with transparent background
  {
    "Everblush/nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('everblush').setup({
        transparent_background = true,
      })
    end,
  },

  -- Additional colorschemes available in picker
  {
    "LazyVim/LazyVim",
    opts = {
      colorschemes = {
        -- Alpha-nvim theme
        {
          "goolord/alpha-nvim",
          name = "alpha",
        },
        -- Aurora - Colorful theme
        {
          "ray-x/aurora",
          name = "aurora",
        },
        -- Bamboo - Warm green theme
        {
          "ribru17/bamboo.nvim",
          name = "bamboo",
        },
        -- Bluloco - Blue and local theme
        {
          "uloco/bluloco.nvim",
          name = "bluloco",
        },
        -- Dracula - Dark theme with vibrant colors
        {
          "Mofiqul/dracula.nvim",
          name = "dracula",
        },
        -- Everforest - Nature-inspired theme
        {
          "neanias/everforest-nvim",
          name = "everforest",
        },
        -- GitHub themes - Official GitHub colorschemes
        {
          "projekt0n/github-nvim-theme",
          name = "github_dark",
        },
        {
          "projekt0n/github-nvim-theme",
          name = "github_light",
        },
        -- Gruber Darker - Dark theme
        {
          "blazkowolf/gruber-darker.nvim",
          name = "gruber-darker",
        },
        -- Lush - Theme framework
        {
          "rktjmp/lush.nvim",
          name = "lush",
        },
        -- Neomodern - Modern theme with all variants
        {
          "casedami/neomodern.nvim",
          name = "neomodern",
        },
        -- Nord - Clean and minimal Arctic theme
        {
          "shaunsingh/nord.nvim",
          name = "nord",
        },
        -- Old World - Classic theme
        {
          "dgox16/oldworld.nvim",
          name = "oldworld",
        },
      },
    },
  },

  
}