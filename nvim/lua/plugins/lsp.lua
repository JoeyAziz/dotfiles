-- LSP: Mason installs + server config overrides
return {
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				-- Go (gopls installed manually via `go install` to avoid Mason version drift)
				-- "golangci-lint",
				-- JSON / YAML
				"json-lsp",
				"yaml-language-server",
				-- Lua
				"lua-language-server",
			})

			-- Never auto-install
			local skip = {
				["shfmt"] = true,
				["markdownlint-cli2"] = true,
				["markdown-toc"] = true,
			}
			opts.ensure_installed = vim.tbl_filter(function(name)
				return not skip[name]
			end, opts.ensure_installed)
		end,
	},

	-- nvim-lspconfig: extra server configurations
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			servers = {
				-- Go: use the system gopls (~/go/bin/gopls), not Mason's copy
				gopls = {
					mason = false,
					cmd = {
						vim.fn.expand("~/go/bin/gopls"),
						"-logfile=/tmp/gopls.log",
						"-rpc.trace",
						"serve",
					},
					settings = {
						gopls = {
							-- Bazel creates a `bazel-<workspace>` symlink at the workspace
							-- root that points back into the source tree; gopls must skip
							-- it or it double-traverses. Set BAZEL_GO_WORKSPACE to your
							-- workspace dir name (e.g. in ~/.zshrc) to add that filter.
							directoryFilters = vim.tbl_filter(function(v)
								return v ~= nil
							end, {
								"-bazel-bin",
								"-bazel-out",
								"-bazel-testlogs",
								"-.ijwb",
								vim.env.BAZEL_GO_WORKSPACE and ("-bazel-" .. vim.env.BAZEL_GO_WORKSPACE) or nil,
							}),
						},
					},
				},
				vtsls = {
					settings = {
						typescript = {
							tsserver = { maxTsServerMemory = 8192 },
						},
					},
				},
				-- YAML: enable schema store for auto-detected schemas (k8s, GitHub Actions, etc.)
				yamlls = {
					settings = {
						yaml = {
							schemaStore = { enable = true, url = "" },
							validate = true,
						},
					},
				},
				marksman = { enabled = false },
			},
		},
	},
}
