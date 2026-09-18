-- blink.cmp:
--   - No auto-popup while typing; trigger manually with <C-Space>
--   - LSP features (hover, signature help, goto def, diagnostics) stay on
--   - Member/property completion (`.`, `->`, `:`) still auto-shows
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Down>"] = {},
      ["<Up>"] = {},
    },
    completion = {
      menu = {
        auto_show = function(ctx)
          return ctx.trigger.kind == "trigger_character"
        end,
      },
      trigger = {
        show_on_keyword = false,
        show_on_trigger_character = true,
      },
    },
    signature = { enabled = true },
  },
}
