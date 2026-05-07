-- Keymaps (LazyVim defaults are in its source; add custom bindings here)
local map = vim.keymap.set
local wk = require("which-key")

-- Bazel
local bazel = require("util.bazel")

map("n", "<leader>bb", function()
	bazel.run("build //...")
end, { desc = "Bazel Build All" })
map("n", "<leader>bt", function()
	bazel.run("test " .. bazel.current_package_target())
end, { desc = "Bazel Test Package" })
map("n", "<leader>bT", function()
	bazel.run("test //...")
end, { desc = "Bazel Test All" })
map("n", "<leader>bs", function()
	local name = bazel.current_test_name()
	if name then
		bazel.run("test " .. bazel.current_package_target() .. " --test_filter=" .. name)
	else
		vim.ui.input({ prompt = "Test filter: " }, function(input)
			if input and input ~= "" then
				bazel.run("test " .. bazel.current_package_target() .. " --test_filter=" .. input)
			end
		end)
	end
end, { desc = "Bazel Test Specific" })
map("n", "<leader>br", function()
	bazel.run("run //...")
end, { desc = "Bazel Run" })
map("n", "<leader>bg", function()
	vim.notify("Running Gazelle...", vim.log.levels.INFO)
	bazel.run("run //:gazelle", function()
		vim.notify("Gazelle done — pre-building workspace in background...", vim.log.levels.INFO)
		bazel.run("build //src/... //pkg/...", function()
			vim.notify("Workspace build done — restarting LSP", vim.log.levels.INFO)
			vim.cmd("LspRestart")
		end)
	end)
end, { desc = "Bazel Gazelle Sync" })

-- My TODO list
wk.add({
	{ "<leader>t", group = "TODO", icon = { icon = "📋", color = "green" } },
})

local myTodo = require("util.todo")
map("n", "<leader>tt", function()
	myTodo.toggle()
end, { desc = "TODO toggle window" })

-- Quick format buffer
map("n", "<leader>bf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format Buffer" })

-- Toggle format on save
map("n", "<leader>uf", function()
	local enabled = not vim.g.autoformat
	vim.g.autoformat = enabled
	vim.notify("Format on save " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Format on Save" })

-- Copy file path relative to cwd
map("n", "<leader>yp", function()
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy Relative File Path" })

-- Open buffer's directory in macOS Finder
map("n", "<leader>oF", function()
	local dir = vim.fn.expand("%:p:h")
	vim.fn.jobstart({ "open", dir }, { detach = true })
	vim.notify("Opened in Finder: " .. dir, vim.log.levels.INFO)
end, { desc = "Open Buffer Dir in Finder" })
