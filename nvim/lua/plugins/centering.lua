-- Center buffer content; neo-tree coexists as the left padding when open
return {
  {
    "shortcuts/no-neck-pain.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>uz", "<cmd>NoNeckPain<cr>", desc = "Toggle centered layout" },
    },
    opts = {
      width = 120,
      autocmds = {
        enableOnVimEnter = true,
        skipEnteringNoNeckPainBuffer = true,
        reloadOnColorSchemeChange = true,
      },
      buffers = {
        scratchPad = { enabled = false },
        bo = { filetype = "no-neck-pain" },
        wo = { fillchars = "eob: " },
      },
      integrations = {
        NeoTree = { reopen = true, position = "left" },
      },
    },
  },
}
