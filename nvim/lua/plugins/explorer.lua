-- Snacks Explorer customization
return {
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				sources = {
					explorer = {
						layout = {
							preset = "vertical",
							preview = true,
							layout = { width = 0.4, height = 0.9 },
						},
						auto_close = true,
						hidden = true, -- show dotfiles by default (toggle with H)
						ignored = true, -- show gitignored files by default (toggle with I)
					},
				},
			},
		},
	},
}
