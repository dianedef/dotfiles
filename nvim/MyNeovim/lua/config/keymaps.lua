-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>uw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Notifications (which-key group)
vim.keymap.set("n", "<leader>nn", "<cmd>Noice history<cr>", { desc = "Afficher notifications" })

vim.keymap.set("n", "<leader>nc", function()
  local ok, manager = pcall(require, "noice.message.manager")
  if ok then
    local messages = manager.get({}, { history = true })
    if messages and #messages > 0 then
      local last = messages[#messages]
      local text = last:content()
      vim.fn.setreg("+", text)
      vim.notify("Copié !", "info")
      return
    end
  end
  vim.notify("Aucun message", "warn")
end, { desc = "Copier dernier message" })

vim.keymap.set("n", "<leader>nC", function()
  local ok, manager = pcall(require, "noice.message.manager")
  if ok then
    local messages = manager.get({}, { history = true })
    if messages and #messages > 0 then
      local texts = {}
      for _, msg in ipairs(messages) do
        table.insert(texts, msg:content())
      end
      vim.fn.setreg("+", table.concat(texts, "\n\n"))
      vim.notify(#messages .. " messages copiés !", "info")
      return
    end
  end
  vim.notify("Aucun message", "warn")
end, { desc = "Copier tous les messages" })
