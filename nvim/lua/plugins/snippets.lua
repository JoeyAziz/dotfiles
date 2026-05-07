return {
  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      if opts then
        require("luasnip").config.setup(opts)
      end
      -- Load friendly-snippets (LazyVim default)
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Load custom project snippets
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
    end,
  },
}
