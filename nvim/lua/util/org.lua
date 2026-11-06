local M = {}

M.dir = vim.fn.expand(vim.env.ORG_DIR or "~/org")

-- UPDATED stamps: on TODO change, refresh `UPDATED: <...>` on the entry and its :project: parent

local STAMP_PAT = "^UPDATED: +<[^>\n]*>"

local function stamp()
  return os.date("UPDATED: <%Y-%m-%d %a %H:%M>")
end

local function heading_level(line)
  local stars = line and line:match("^(%*+)%s")
  return stars and #stars or nil
end

local function is_project(line)
  local tags = line:match("%s(:[^%s]+:)%s*$")
  return tags ~= nil and tags:find(":project:", 1, true) ~= nil
end

local function refresh_stamp(ed, hl)
  local n = ed.count()
  local stop = n + 1
  for i = hl + 1, n do
    if heading_level(ed.get(i)) then
      stop = i
      break
    end
  end

  local found
  local i = hl + 1
  while i < stop do
    if ed.get(i):match(STAMP_PAT) then
      if found then
        ed.delete(i)
        stop = stop - 1
      else
        ed.set(i, (ed.get(i):gsub(STAMP_PAT, stamp(), 1)))
        found = true
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  if found then
    return
  end

  -- insert after planning line and property drawer
  local at = hl + 1
  if at < stop and ed.get(at):match("^%s*[A-Z]+:%s*[<%[]") then
    at = at + 1
  end
  if at < stop and ed.get(at):match("^%s*:PROPERTIES:%s*$") then
    for j = at + 1, stop - 1 do
      if ed.get(j):match("^%s*:END:%s*$") then
        at = j + 1
        break
      end
    end
  end
  ed.insert(at, stamp())
end

local function touch(ed, row)
  local level = heading_level(ed.get(row))
  if not level then
    return
  end
  refresh_stamp(ed, row)
  for i = row - 1, 1, -1 do
    local l = heading_level(ed.get(i))
    if l and l < level then
      if is_project(ed.get(i)) then
        refresh_stamp(ed, i)
        return
      end
      level = l
    end
  end
end

local function buffer_editor(buf)
  return {
    count = function() return vim.api.nvim_buf_line_count(buf) end,
    get = function(i) return vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] end,
    set = function(i, s) vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { s }) end,
    insert = function(i, s) vim.api.nvim_buf_set_lines(buf, i - 1, i - 1, false, { s }) end,
    delete = function(i) vim.api.nvim_buf_set_lines(buf, i - 1, i, false, {}) end,
  }
end

local function table_editor(lines)
  return {
    count = function() return #lines end,
    get = function(i) return lines[i] end,
    set = function(i, s) lines[i] = s end,
    insert = function(i, s) table.insert(lines, i, s) end,
    delete = function(i) table.remove(lines, i) end,
  }
end

local function find_row(ed, row, rest)
  local function matches(line)
    return line ~= nil and heading_level(line) ~= nil and line:sub(-#rest) == rest
  end
  if matches(ed.get(row)) then
    return row
  end
  for i = 1, ed.count() do
    if matches(ed.get(i)) then
      return i
    end
  end
end

local function touch_file(filename, row, rest)
  local buf = vim.fn.bufnr(filename)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    local ed = buffer_editor(buf)
    local target = find_row(ed, row, rest)
    if not target then
      return
    end
    local was_modified = vim.bo[buf].modified
    touch(ed, target)
    if not was_modified then
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! noautocmd write") end)
    end
    return
  end

  if vim.fn.filereadable(filename) == 0 then
    return
  end
  local lines = vim.fn.readfile(filename)
  local ed = table_editor(lines)
  local target = find_row(ed, row, rest)
  if target then
    touch(ed, target)
    vim.fn.writefile(lines, filename)
  end
end

function M.setup_updated_stamps()
  local EventManager = require("orgmode.events")
  local Events = require("orgmode.events.types")
  EventManager.listen(Events.TodoChanged, function(event)
    local headline = event.headline
    if not headline or not headline:get_todo() then
      return
    end
    local filename = headline.file.filename
    local buf = vim.fn.bufnr(filename)
    if buf == -1 then
      return
    end
    local row = headline:get_range().start_line
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    if not line then
      return
    end
    local rest = line:gsub("^%*+%s+", ""):gsub("^[%u%-]+%s+", "", 1)
    -- after orgmode writes CLOSED
    vim.schedule(function()
      touch_file(filename, row, rest)
    end)
  end)
end

-- Git sync: pull --rebase, add, commit, push

local function show_failure(step, out)
  vim.cmd("botright 12new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, "\n"))
  vim.notify("org sync failed at: git " .. step, vim.log.levels.ERROR)
end

function M.sync()
  if vim.fn.isdirectory(M.dir .. "/.git") == 0 then
    vim.notify(M.dir .. " is not a git repo", vim.log.levels.ERROR)
    return
  end
  vim.cmd("silent! wall")
  local msg = ("sync from %s — %s"):format(vim.fn.hostname(), os.date("%Y-%m-%d %H:%M"))
  local steps = {
    { "pull", "--rebase", "--autostash" },
    { "add", "-A" },
    { "commit", "-m", msg },
    { "push" },
  }
  local function run(i)
    if i > #steps then
      vim.notify("org sync: done")
      return
    end
    local args = steps[i]
    vim.system(vim.list_extend({ "git" }, args), { cwd = M.dir, text = true }, function(res)
      vim.schedule(function()
        local out = (res.stdout or "") .. (res.stderr or "")
        local nothing = args[1] == "commit" and out:find("nothing to commit")
        if res.code ~= 0 and not nothing then
          return show_failure(args[1], out)
        end
        run(i + 1)
      end)
    end)
  end
  run(1)
end

return M
