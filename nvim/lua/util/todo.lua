local M = {}
local win = nil
local buf = nil

local todo_file = vim.fn.stdpath("data") .. "/todos.md"

local function set_keymaps(b)
	vim.keymap.set("n", "q", function()
		require("util.todo").save()
		require("util.todo").toggle()
	end, { buffer = b, desc = "TODO save and close" })

	vim.keymap.set("n", "a", function()
		require("util.todo").addTodoItem()
	end, { buffer = b, desc = "TODO Add item" })

	vim.keymap.set("n", "<CR>", function()
		require("util.todo").toggleTodoItem()
	end, { buffer = b, desc = "TODO Toggle item" })
end

local function with_no_autocmds(fn)
	local saved = vim.o.eventignore
	vim.o.eventignore = "all"
	local ok, err = pcall(fn)
	vim.o.eventignore = saved
	if not ok then
		error(err)
	end
end

local function ensure_buffer()
	if buf and vim.api.nvim_buf_is_valid(buf) then
		return buf
	end

	with_no_autocmds(function()
		buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buf, todo_file)
		if vim.fn.filereadable(todo_file) == 1 then
			local lines = vim.fn.readfile(todo_file)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		end
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].filetype = "markdown"
		vim.bo[buf].modified = false
	end)

	set_keymaps(buf)
	return buf
end

local function open_window()
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.6)

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local b = ensure_buffer()
	with_no_autocmds(function()
		win = vim.api.nvim_open_win(b, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = "rounded",
			title = " # Todo",
			title_pos = "center",
		})
	end)
end

function M.toggle()
	if win and vim.api.nvim_win_is_valid(win) then
		with_no_autocmds(function()
			vim.api.nvim_win_close(win, false)
		end)
		win = nil
		return
	end

	open_window()
end

function M.save()
	if buf and vim.api.nvim_buf_is_valid(buf) then
		with_no_autocmds(function()
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("write")
			end)
		end)
	end
end

function M.addTodoItem()
	local buffer = ensure_buffer()
	vim.api.nvim_set_current_buf(buffer)

	local todo_item = vim.fn.input("Todo: ")
	if todo_item == "" then
		return
	end

	local line = "- [ ] " .. todo_item
	vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { line })
end

function M.toggleTodoItem()
	local buffer = ensure_buffer()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1

	local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
	if not line then
		return
	end

	local new_line

	if line:match("%- %[%s%]") then
		-- unchecked → checked
		new_line = line:gsub("%- %[%s%]", "- [x]", 1)
	elseif line:match("%- %[x%]") then
		-- checked → unchecked
		new_line = line:gsub("%- %[x%]", "- [ ]", 1)
	else
		return
	end

	vim.api.nvim_buf_set_lines(buffer, row, row + 1, false, { new_line })
end

return M
