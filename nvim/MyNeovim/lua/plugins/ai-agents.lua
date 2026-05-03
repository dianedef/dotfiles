-- AI Coding Agents (Claude Code)
local CLAUDE_AUTONOMOUS_CMD = "claude --permission-mode bypassPermissions"

local function half_height()
  return math.floor(vim.o.lines / 2)
end

local function sync_terminal_height()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if not cfg.relative or cfg.relative == "" then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "snacks_terminal" then
          pcall(vim.api.nvim_win_set_height, win, half_height())
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
