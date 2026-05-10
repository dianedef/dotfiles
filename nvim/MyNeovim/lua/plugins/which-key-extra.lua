return {
  "folke/which-key.nvim",
  enabled = true,
  optional = true,
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        vim.schedule(function()
          local ok, view = pcall(require, "which-key.view")
          if not ok or view._dotfiles_submenu_spacing_patched then
            return
          end
          view._dotfiles_submenu_spacing_patched = true

          local orig_item = view.item
          view.item = function(node, opts)
            local item = orig_item(node, opts)
            local parent_path = opts and opts.parent and opts.parent.path or {}
            local is_submenu = #parent_path > 1

            if
              is_submenu
              and item
              and item.icon
              and item.icon ~= ""
              and item.desc
              and item.desc ~= ""
              and not item.desc:match("^%s")
            then
              item.desc = " " .. item.desc
            end

            return item
          end
        end)
      end,
    })
  end,
  opts = {
    icons = {
      rules = {
        { pattern = "ai", icon = "🤖", color = "purple" },
        { pattern = "cheat", icon = "📖", color = "yellow" },
        { pattern = "keywordprg", icon = "", color = "azure" },
        { pattern = "neotree", icon = "", color = "blue" },
      },
    },
    spec = {
      { "<leader>a",    group = "AI" },
      { "<leader>ac",   group = "Claude" },
      { "<leader>ag",   group = "Gemini" },
      { "<leader>aj",   group = "Agentic" },
      { "<leader>ak",   group = "Codex" },
      { "<leader>ap",   group = "Copilot" },
      { "<leader>au",   group = "Augment" },
      { "<leader>ax",   group = "Avante" },
      { "<leader>e",    group = "Explorer" },
      { "<leader><tab>", group = "Tabs" },
      { "<leader>b",    group = "Buffer" },
      { "<leader>c",    group = "Code" },
      { "<leader>d",    group = "Debug" },
      { "<leader>dp",   group = "Profiler" },
      { "<leader>f",    group = "File/Find" },
      { "<leader>g",    group = "Git" },
      { "<leader>gh",   group = "Hunks" },
      { "<leader>q",    group = "Quit/Session" },
      { "<leader>s",    group = "Search" },
      { "<leader>u",    group = "UI" },
      { "<leader>w",    group = "Windows" },
      { "<leader>n",    group = "Notifications" },
      { "<leader>x",    group = "Diagnostics/Quickfix" },
      { "[",            group = "Prev" },
      { "]",            group = "Next" },
      { "g",            group = "Goto" },
      { "gs",           group = "Surround" },
      { "z",            group = "Fold" },
    },
  },
}
