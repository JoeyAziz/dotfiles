-- Options (LazyVim sets sensible defaults; add overrides here)

-- Route gopls through a Bazel-aware go/packages driver when inside a Bazel workspace.
-- Shell config has this disabled; we inject it into Neovim's env so gopls
-- inherits it regardless of how Neovim was launched.
local function in_bazel_workspace()
  for _, marker in ipairs({ "WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel" }) do
    if vim.fn.findfile(marker, ".;") ~= "" then return true end
  end
  return false
end

local driver = vim.fn.expand("~/bin/gopackagesdriver")
if vim.fn.executable(driver) == 1 and in_bazel_workspace() then
  vim.env.GOPACKAGESDRIVER = driver
end

local opt = vim.opt

opt.relativenumber = true   -- relative line numbers
opt.scrolloff = 8           -- lines of context when scrolling
opt.timeoutlen = 300        -- faster which-key popup
opt.termguicolors = true    -- use 24-bit RGB color instead of terminal's limited palette
opt.cursorline = false      -- no highlight on the current line
opt.linespace = 4           -- pixels between lines (GUI/Neovide only; terminal ignores)

-- Use system clipboard
opt.clipboard = "unnamedplus"

-- Spelling
opt.spell = true
opt.spelllang = "en_us"

-- Hide tab characters (set to spaces so nothing is rendered)
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Go: use tabs (gofmt convention)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    opt.expandtab = false
    opt.tabstop = 4
    opt.shiftwidth = 4
  end,
})
