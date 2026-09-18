return {
	{
		"kungfusheep/mfd.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = { colorscheme = "mfd-flir" },
	},
	-- Keep fallbacks installed but lazy-loaded
	{ "rebelot/kanagawa.nvim", lazy = true, opts = { theme = "wave" } },
	{ "slugbyte/lackluster.nvim", lazy = true },
}
