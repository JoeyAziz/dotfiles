return {
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = "gruber-darker" },
	},
	-- Keep fallbacks installed but lazy-loaded
	{ "rebelot/kanagawa.nvim", lazy = true, opts = { theme = "wave" } },
	{ "slugbyte/lackluster.nvim", lazy = true },
}
