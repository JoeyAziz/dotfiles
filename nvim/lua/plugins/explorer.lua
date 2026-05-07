-- Snacks Explorer customization
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,  -- show dotfiles by default (toggle with H)
            ignored = true, -- show gitignored files by default (toggle with I)
          },
        },
      },
    },
  },
}
