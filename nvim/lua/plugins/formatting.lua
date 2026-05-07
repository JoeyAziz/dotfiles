-- Format on save + formatter configuration
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        javascript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescript      = { "prettier" },
        typescriptreact = { "prettier" },
        css             = { "prettier" },
        json            = { "prettier" },
        jsonc           = { "prettier" },
        html            = { "prettier" },
        markdown        = { "prettier" },
        yaml            = { "prettier" },
      })

      -- Go: goimports first (organises imports), then gofmt
      opts.formatters_by_ft.go = { "goimports", "gofmt" }

      opts.timeout_ms = 3000
    end,
  },

  -- Mason: auto-install formatters
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "prettier",
        "goimports",
      })
    end,
  },
}
