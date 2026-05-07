-- UI overrides
return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      -- Disable all animations (window open/close, etc.)
      animate = { enabled = false },
      -- Disable smooth scrolling
      scroll = { enabled = false },
      -- Disable indent | lines and scope highlight
      indent = { enabled = false },
      scope = { enabled = false },
    },
  },
}
