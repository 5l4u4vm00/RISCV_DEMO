-- ============================================================================
-- Hotkey Configuration (RISC-V CPU Development Specific)
-- ============================================================================

return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>v"] = { name = "+verilog" },
        ["<leader>r"] = { name = "+riscv" },
      },
    },
  },

  -- Custom hotkeys
  {
    "LazyVim/LazyVim",
    keys = {
      -- ========================================
      -- Verilog Development Hotkeys
      -- ========================================

      -- Compile simulation
      {
        "<leader>vs",
        "<cmd>!make sim<cr>",
        desc = "Run Verilog Simulation",
      },

      -- Open waveform
      {
        "<leader>vw",
        "<cmd>!make wave &<cr>",
        desc = "Open GTKWave",
      },

      -- Clean
      {
        "<leader>vc",
        "<cmd>!make clean<cr>",
        desc = "Clean Build Files",
      },

      -- ========================================
      -- RISC-V Development Hotkeys
      -- ========================================

      -- Compile RISC-V program
      {
        "<leader>rc",
        "<cmd>!make compile_sw<cr>",
        desc = "Compile RISC-V Software",
      },

      -- View disassembly
      {
        "<leader>rd",
        "<cmd>vsplit sw/test.dump<cr>",
        desc = "View Disassembly",
      },

      -- ========================================
      -- Terminal
      -- ========================================

      -- Open terminal
      {
        "<leader>tt",
        "<cmd>terminal<cr>",
        desc = "Open Terminal",
      },

      -- ========================================
      -- Quick Navigation
      -- ========================================

      -- Jump to RTL directory
      {
        "<leader>fr",
        "<cmd>Telescope find_files cwd=rtl<cr>",
        desc = "Find RTL Files",
      },

      -- Jump to Testbench directory
      {
        "<leader>ft",
        "<cmd>Telescope find_files cwd=tb<cr>",
        desc = "Find Testbench Files",
      },
    },
  },
}
