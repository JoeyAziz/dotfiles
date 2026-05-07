-- LSP: Mason installs + server config overrides
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- TypeScript / React
        "typescript-language-server",
        "eslint-lsp",
        -- TailwindCSS
        "tailwindcss-language-server",
        -- Go (gopls installed manually via `go install` to avoid Mason version drift)
        "golangci-lint",
        -- JSON / YAML / SQL
        "json-lsp",
        "yaml-language-server",
        "sqls",
        -- Lua
        "lua-language-server",
      })
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
              directoryFilters = {
                "-bazel-bin",
                "-bazel-out",
                "-bazel-testlogs",
                "-.ijwb",
              },
            },
          },
        },
        -- TailwindCSS: extend file type support to include .tsx
        tailwindcss = {
          filetypes = {
            "html",
            "css",
            "scss",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
        -- ts_ls: ensure TSX/JSX are covered
        ts_ls = {
          filetypes = {
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "javascript",
            "javascriptreact",
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
        -- SQL: basic language server
        sqls = {},
        -- Protobuf: buf LSP (uses `buf lsp serve`, installed via brew)
        buf_ls = {},
      },
    },
  },
}
