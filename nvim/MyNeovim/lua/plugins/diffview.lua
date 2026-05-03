local function open_origin_diff()
  local ref = vim.fn.systemlist({ "git", "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })[1]

  if vim.v.shell_error ~= 0 or not ref or ref == "" then
    for _, candidate in ipairs({ "origin/main", "origin/master" }) do
      vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", candidate })
      if vim.v.shell_error == 0 then
        ref = candidate
        break
      end
    end
  end

  if ref and ref ~= "" then
    vim.cmd("DiffviewOpen " .. ref .. "...HEAD")
  else
    vim.notify("Aucune branche origin trouvée, ouverture du diff local", vim.log.levels.WARN)
    vim.cmd("DiffviewOpen")
  end
end

return {
  "sindrets/diffview.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewFocusFiles",
    "DiffviewToggleFiles",
    "DiffviewRefresh",
  },
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
    { "<leader>gV", open_origin_diff, desc = "Diffview origin" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
  },
  opts = function()
    local actions = require("diffview.actions")

    return {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_vertical",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_vertical",
          disable_diagnostics = true,
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_vertical",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "list",
        win_config = function()
          return {
            type = "split",
            position = "top",
            height = math.max(6, math.floor(vim.o.lines * 0.25)),
            win_opts = {
              wrap = false,
            },
          }
        end,
      },
      file_history_panel = {
        win_config = function()
          return {
            type = "split",
            position = "top",
            height = math.max(6, math.floor(vim.o.lines * 0.25)),
            win_opts = {
              wrap = false,
            },
          }
        end,
      },
      keymaps = {
        file_panel = {
          { "n", "j", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<down>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<ScrollWheelDown>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "k", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          { "n", "<up>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          { "n", "<ScrollWheelUp>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
        },
        file_history_panel = {
          { "n", "j", actions.select_next_entry, { desc = "Open the next history entry" } },
          { "n", "<down>", actions.select_next_entry, { desc = "Open the next history entry" } },
          { "n", "<ScrollWheelDown>", actions.select_next_entry, { desc = "Open the next history entry" } },
          { "n", "k", actions.select_prev_entry, { desc = "Open the previous history entry" } },
          { "n", "<up>", actions.select_prev_entry, { desc = "Open the previous history entry" } },
          { "n", "<ScrollWheelUp>", actions.select_prev_entry, { desc = "Open the previous history entry" } },
        },
      },
    }
  end,
}
