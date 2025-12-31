-- ============================================================================
-- Editor Basic Settings
-- ============================================================================

return {
  -- Adjust LazyVim default settings
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },

  -- Color theme
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
    },
  },

  -- Status line shows more information
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_c = {
        { "filename", path = 1 }, -- Show relative path
      }
    end,
  },

  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Enhanced search
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = {
          "%.vcd",
          "%.fst",
          "%.o",
          "%.elf",
          "sim/",
        },
      },
    },
  },
}
