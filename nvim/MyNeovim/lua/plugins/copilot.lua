return {
  "zbirenbaum/copilot.lua",
  enabled = true,
  build = ":Copilot auth",
  cmd = "Copilot",
  lazy = false,
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    panel = { enabled = false },
    suggestion = {
      enabled = false,
      auto_trigger = false,
      keymap = {
        accept = false,
        prev = "<M-[>",
        next = "<M-]>",
        dismiss = false,
      },
    },
    filetypes = {
      yaml = true,
      markdown = true,
      gitcommit = true,
      gitrebase = true,
      hgcommit = true,
      svn = true,
      ["."] = true,
    },
  },
  config = function(_, opts)
    require("copilot").setup(opts)

    vim.keymap.set("i", "<Tab>", function()
      if require("copilot.suggestion").is_visible() then
        require("copilot.suggestion").accept()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
      end
    end, { silent = true })
  end,
}
