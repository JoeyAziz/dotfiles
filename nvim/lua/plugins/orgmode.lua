local org = require("util.org")

local function f(name)
  return org.dir .. "/" .. name
end

local created = ":PROPERTIES:\n:CREATED: %U\n:END:\n"
local updated = "UPDATED: <%<%Y-%m-%d %a %H:%M>>\n"

-- Month view starts on the 1st
local day = tonumber(os.date("%d"))
local month_start = day > 1 and ("-" .. (day - 1) .. "d") or nil

-- TODO matcher only takes single-word keywords, so "in progress" = open and not TODO
local function project_blocks()
  return {
    { type = "tags_todo", match = "+project/TODO", org_agenda_overriding_header = "Projects — open" },
    { type = "tags_todo", match = "+project/-TODO", org_agenda_overriding_header = "Projects — in progress" },
    { type = "tags", match = "+project/DONE|CANCELLED", org_agenda_overriding_header = "Projects — done" },
  }
end

return {
  {
    "nvim-orgmode/orgmode",
    ft = "org",
    keys = {
      { "<leader>oa", function() require("orgmode").action("agenda.prompt") end, desc = "Org agenda" },
      { "<leader>oc", function() require("orgmode").action("capture.prompt") end, desc = "Org capture" },
      { "<leader>oS", function() org.sync() end, desc = "Org git sync" },
    },
    opts = {
      org_agenda_files = { f("inbox.org"), f("tasks.org"), f("projects.org"), f("journal.org") },
      org_default_notes_file = f("inbox.org"),
      org_todo_keywords = {
        "TODO(t)", "IN-PROGRESS(i)", "WAITING(w)", "QA(q)", "NOT-ON-PROD(n)",
        "|", "DONE(d)", "CANCELLED(c)",
      },
      org_log_done = "time",
      org_log_into_drawer = "LOGBOOK",
      org_tags_exclude_from_inheritance = { "project" },
      org_id_link_to_org_use_id = true,
      org_archive_location = f("archive/%s_archive::"),
      org_adapt_indentation = false,
      org_hide_emphasis_markers = true,
      org_hide_leading_stars = true,
      org_ellipsis = " ▾",
      org_agenda_span = "week",
      calendar_week_start_day = 1,

      org_capture_templates = {
        t = {
          description = "Task",
          target = f("tasks.org"),
          headline = "Tasks",
          template = "* TODO %?\n" .. created .. updated,
        },
        i = {
          description = "Inbox",
          target = f("inbox.org"),
          headline = "Inbox",
          template = "* TODO %?\n" .. created .. updated,
        },
        p = {
          description = "Project",
          target = f("projects.org"),
          template = "* TODO %^{Project title} [/] :project:\n" .. created .. updated
            .. "\n*Problem:* %^{Problem statement}\n\n** Goals\n- %^{First goal}\n- \n\n"
            .. "** Milestones\n*** TODO %^{First milestone}\n\n** Tasks\n*** TODO %?\n",
        },
        j = {
          description = "Journal",
          target = f("journal.org"),
          datetree = true,
          template = "* %?\n<%<%Y-%m-%d %a %H:%M>>\n",
        },
        n = {
          description = "Note",
          target = f("notes.org"),
          headline = "Notes",
          template = "** %?\n" .. created,
        },
      },

      org_agenda_custom_commands = {
        d = {
          description = "Dashboard",
          types = vim.list_extend({
            { type = "agenda", org_agenda_span = "month", org_agenda_start_day = month_start },
          }, project_blocks()),
        },
        w = {
          description = "Week review",
          types = {
            { type = "agenda", org_agenda_span = "week" },
            { type = "tags_todo", match = "-project/-TODO-WAITING", org_agenda_overriding_header = "Tasks — in progress" },
            { type = "tags_todo", match = "-project/WAITING", org_agenda_overriding_header = "Tasks — waiting" },
            { type = "tags_todo", match = "-project/TODO", org_agenda_overriding_header = "Tasks — todo" },
          },
        },
        p = {
          description = "Projects",
          types = project_blocks(),
        },
      },
    },
    config = function(_, opts)
      require("orgmode").setup(opts)
      org.setup_updated_stamps()
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = { org = { "orgmode" } },
        providers = {
          orgmode = { name = "Orgmode", module = "orgmode.org.autocompletion.blink", fallbacks = { "buffer" } },
        },
      },
    },
  },
}
