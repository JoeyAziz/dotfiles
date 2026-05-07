-- Bazel / Starlark support
return {
  -- which-key group label for <leader>b
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer/Bazel", icon = "" },
      },
    },
  },

  -- Formatter: buildifier for .bzl / BUILD files
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.bzl = { "buildifier" }
    end,
  },

}
