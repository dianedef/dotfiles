-- AI Coding Agents (Claude Code)
local CLAUDE_AUTONOMOUS_CMD = "claude --permission-mode bypassPermissions"

local function half_height()
  return math.floor(vim.o.lines / 2)
end

local function sync_terminal_height()
  local panel_resize = require("config.panel-resize")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if not cfg.relative or cfg.relative == "" then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "snacks_terminal" then
          local override = panel_resize.get_terminal_size_override(buf)
          if override then
            -- Respect the user's manually chosen size
            if override.orientation == "horizontal" then
              pcall(vim.api.nvim_win_set_height, win, override.size)
            else
              pcall(vim.api.nvim_win_set_width, win, override.size)
            end
          else
            pcall(vim.api.nvim_win_set_height, win, half_height())
          end
        end
      end
    end
  end
end

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("claude_terminal_resize", { clear = true }),
  callback = vim.schedule_wrap(sync_terminal_height),
})

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ach",
        function()
          Snacks.terminal.open(CLAUDE_AUTONOMOUS_CMD, {
            win = { position = "bottom", height = half_height() },
          })
        end,
        desc = "Claude CLI ─",
      },
      {
        "<leader>acv",
        function()
          Snacks.terminal.open(CLAUDE_AUTONOMOUS_CMD, {
            win = { position = "right", width = 0.5 },
          })
        end,
        desc = "Claude CLI │",
      },
      {
        "<leader>acH",
        function()
          Snacks.terminal.open(CLAUDE_AUTONOMOUS_CMD, {
            cwd = vim.fn.expand("%:p:h"),
            win = { position = "bottom", height = half_height() },
          })
        end,
        desc = "Claude CLI here ─",
      },
      {
        "<leader>acV",
        function()
          Snacks.terminal.open(CLAUDE_AUTONOMOUS_CMD, {
            cwd = vim.fn.expand("%:p:h"),
            win = { position = "right", width = 0.5 },
          })
        end,
        desc = "Claude CLI here │",
      },
    },
  },
}
