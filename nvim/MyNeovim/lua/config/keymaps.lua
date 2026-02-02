-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>uw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Notifications (which-key group)
local function copy_to_clipboard(text)
  -- OSC 52 pour copier via terminal (fonctionne sur SSH/Termux)
  local b64 = vim.base64.encode(text)
  local osc52 = string.format("\027]52;c;%s\027\\", b64)
  io.stdout:write(osc52)
  -- Aussi sauvegarder dans un fichier
  local f = io.open("/tmp/nvim_notif.txt", "w")
  if f then
    f:write(text)
    f:close()
  end
end

vim.keymap.set("n", "<leader>nn", "<cmd>Noice history<cr>", { desc = "Afficher notifications" })

vim.keymap.set("n", "<leader>nc", function()
  local ok, manager = pcall(require, "noice.message.manager")
  if ok then
    local messages = manager.get({}, { history = true })
    if messages and #messages > 0 then
      local last = messages[#messages]
      local text = last:content()
      copy_to_clipboard(text)
      vim.notify("Copié ! (aussi dans /tmp/nvim_notif.txt)", "info")
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
      local text = table.concat(texts, "\n\n")
      copy_to_clipboard(text)
      vim.notify(#messages .. " messages copiés ! (aussi dans /tmp/nvim_notif.txt)", "info")
      return
    end
  end
  vim.notify("Aucun message", "warn")
end, { desc = "Copier tous les messages" })
