-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Snacks explorer under the Explorer group (leader e)
-- Override the default <leader>e and <leader>E remaps from snacks_explorer extra
pcall(vim.keymap.del, "n", "<leader>e")
pcall(vim.keymap.del, "n", "<leader>E")
vim.keymap.set("n", "<leader>es", function() Snacks.explorer({ cwd = LazyVim.root() }) end, { desc = "Snacks Explorer (root)" })
vim.keymap.set("n", "<leader>eS", function() Snacks.explorer() end, { desc = "Snacks Explorer (cwd)" })

-- Move Buffers picker under Buffer group
vim.keymap.del("n", "<leader>,")
vim.keymap.set("n", "<leader>bf", function() Snacks.picker.buffers() end, { desc = "Find Buffers" })

-- Move split commands under Windows group
vim.keymap.del("n", "<leader>-")
vim.keymap.del("n", "<leader>|")
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>uw", ":set wrap!<CR>", { desc = "Toggle wrap" })

local function switch_to_other_buffer()
  local alt = vim.fn.bufnr("#")
  if alt <= 0 or not vim.api.nvim_buf_is_valid(alt) then
    vim.notify("Aucun buffer alternatif", vim.log.levels.WARN)
    return
  end

  vim.cmd("buffer " .. alt)
end

vim.keymap.set("n", "<leader>bb", switch_to_other_buffer, { desc = "Switch to Other Buffer" })
vim.keymap.del("n", "<leader>`")

vim.keymap.set("n", "<leader>h", function()
  local path = vim.fn.expand("~/dotfiles/nvim/MyNeovim/Cheat Sheet.md")
  local target = vim.uv.fs_realpath(path) or vim.fn.fnamemodify(path, ":p")
  local current_name = vim.api.nvim_buf_get_name(0)
  local current = current_name ~= "" and (vim.uv.fs_realpath(current_name) or vim.fn.fnamemodify(current_name, ":p")) or ""

  local function close_and_return()
    local buf = vim.api.nvim_get_current_buf()
    local alt = vim.fn.bufnr("#")
    if alt > 0 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) then
      vim.cmd("buffer " .. alt)
    else
      vim.cmd("enew")
    end
    pcall(vim.api.nvim_buf_delete, buf, { force = false })
  end

  if current == target then
    close_and_return()
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
  vim.bo.buflisted = false

  vim.keymap.set("n", "q", close_and_return, { buffer = true, desc = "Fermer cheatsheet" })
  vim.keymap.set("n", "<leader>bd", close_and_return, { buffer = true, desc = "Fermer cheatsheet" })
  vim.keymap.set("n", "<leader>wd", close_and_return, { buffer = true, desc = "Fermer cheatsheet" })
end, { desc = "Cheat Sheet" })

require("shipflow").setup()

-- Explicit mouse wheel scroll (fixes scroll down through mosh/tmux)
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelUp>", "3<C-y>", { desc = "Scroll up" })
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelDown>", "3<C-e>", { desc = "Scroll down" })
vim.keymap.set("i", "<ScrollWheelUp>", "<C-o>3<C-y>", { desc = "Scroll up" })
vim.keymap.set("i", "<ScrollWheelDown>", "<C-o>3<C-e>", { desc = "Scroll down" })

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
