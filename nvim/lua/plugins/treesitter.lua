-- Treesitter: ensure all needed grammars are installed
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"tsx",
				"typescript",
				"javascript",
				"css",
				"html",
				"json",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"starlark", -- Bazel
				"sql",
				"yaml",
				"ssh_config",
				"proto", -- Protocol Buffers
			})
		end,
	},
}
