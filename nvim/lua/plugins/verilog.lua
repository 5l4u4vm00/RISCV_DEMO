-- ============================================================================
-- Verilog / HDL Development Plugins
-- ============================================================================

return {
  -- Verilog syntax highlighting and support
  {
    "vhda/verilog_systemverilog.vim",
    ft = { "verilog", "systemverilog" },
    config = function()
      -- Auto-fold settings
      vim.g.verilog_syntax_fold_lst = "all"
    end,
  },

  -- Tree-sitter Verilog support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "verilog",
          "c",
          "cpp",
          "python",
          "lua",
          "bash",
          "make",
        })
      end
    end,
  },

  -- LSP configuration (Verilog Language Server)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Verible (Verilog/SystemVerilog)
        verible = {
          cmd = { "verible-verilog-ls" },
          filetypes = { "verilog", "systemverilog" },
        },
        -- HDL Checker (generic HDL)
        hdl_checker = {
          cmd = { "hdl_checker", "--lsp" },
          filetypes = { "verilog", "systemverilog", "vhdl" },
        },
        -- clangd for C/C++ (Verilator testbench)
        clangd = {},
        -- Python (cocotb)
        pyright = {},
      },
    },
  },

  -- Auto formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        verilog = { "verible_format" },
        systemverilog = { "verible_format" },
        python = { "black" },
      },
      formatters = {
        verible_format = {
          command = "verible-verilog-format",
          args = { "-" },
        },
      },
    },
  },
}
