-- Autocmds (LazyVim sets sensible defaults; add custom autocmds here)

-- Silence known-noisy gopls log messages (workspace-load fallout on large Bazel repos)
do
  local orig = vim.lsp.handlers["window/logMessage"] or function() end
  local noisy = {
    "no package metadata for file",
    "no highlight: getting package for Highlight",
    "reloading workspace: packages.Load error",
    "MetadataForFile: packages.Load error",
    "errors loading workspace: packages.Load error",
    "initial workspace load failed: packages.Load error",
  }
  vim.lsp.handlers["window/logMessage"] = function(err, result, ctx, config)
    if result and type(result.message) == "string" then
      for _, needle in ipairs(noisy) do
        if result.message:find(needle, 1, true) then return end
      end
    end
    return orig(err, result, ctx, config)
  end
end

-- Bazel filetype detection
vim.filetype.add({
  filename = {
    ["BUILD"] = "bzl",
    ["BUILD.bazel"] = "bzl",
    ["WORKSPACE"] = "bzl",
    ["WORKSPACE.bazel"] = "bzl",
    [".bazelrc"] = "bazelrc",
  },
  extension = {
    bzl = "bzl",
  },
})
