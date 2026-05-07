-- Bazel utilities
local M = {}

function M.run(args, on_success)
  if not on_success then
    vim.cmd("botright split")
    vim.cmd("terminal bazel " .. args)
    return
  end

  -- Run silently as a job, call on_success when exit code is 0
  local output = {}
  vim.fn.jobstart("bazel " .. args, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data) vim.list_extend(output, data) end,
    on_stderr = function(_, data) vim.list_extend(output, data) end,
    on_exit = function(_, code)
      if code == 0 then
        on_success()
      else
        vim.notify("bazel " .. args .. " failed:\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end

function M.find_workspace_root(dir)
  local search = dir
  while search ~= "/" do
    for _, marker in ipairs({ "WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel" }) do
      if vim.fn.filereadable(search .. "/" .. marker) == 1 then
        return search
      end
    end
    search = vim.fn.fnamemodify(search, ":h")
  end
end

function M.current_package_target()
  local dir = vim.fn.expand("%:p:h")
  local root = M.find_workspace_root(dir)
  if not root then
    vim.notify("No Bazel workspace found", vim.log.levels.WARN)
    return "//..."
  end
  local rel = dir:sub(#root + 2)
  return rel ~= "" and ("//" .. rel .. ":all") or "//..."
end

function M.current_test_name()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then return nil end
  local func_name = nil

  -- Walk up the syntax tree to find the enclosing function_declaration
  while node do
    if node:type() == "function_declaration" then
      for child in node:iter_children() do
        if child:type() == "identifier" then
          local name = vim.treesitter.get_node_text(child, 0)
          if name:match("^Test") then
            func_name = name
          end
          break
        end
      end
      break
    end
    node = node:parent()
  end

  if not func_name then return nil end

  -- Also check if cursor is inside a t.Run("subtest") call
  local cursor_line = vim.fn.line(".")
  local func_line = vim.fn.search("^func " .. func_name, "bcnW")
  if func_line > 0 then
    local lines = vim.api.nvim_buf_get_lines(0, func_line - 1, cursor_line, false)
    for i = #lines, 1, -1 do
      local subtest = lines[i]:match('t%.Run%("([^"]+)"')
      if subtest then
        return func_name .. "/" .. subtest:gsub("%s+", "_")
      end
    end
  end

  return func_name
end

return M
