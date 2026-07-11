-- Lightweight Termux keymaps. Keep this config independent from LazyVim.
vim.keymap.set("t", "<C-Space>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

local function has_snacks()
  return type(_G.Snacks) == "table"
end

-- Root/cwd convention under <leader>: lowercase = current working directory, uppercase = project root.
pcall(vim.keymap.del, "n", "<leader>e")
pcall(vim.keymap.del, "n", "<leader>E")
vim.keymap.set("n", "<leader>es", function()
  if has_snacks() then
    Snacks.explorer()
  else
    vim.cmd("Explore")
  end
end, { desc = "Explorer (cwd)" })
vim.keymap.set("n", "<leader>eS", function()
  if has_snacks() then
    Snacks.explorer({ cwd = vim.fn.getcwd() })
  else
    vim.cmd("Explore")
  end
end, { desc = "Explorer (cwd)" })

pcall(vim.keymap.del, "n", "<leader>,")
vim.keymap.set("n", "<leader>bf", function()
  if has_snacks() then
    Snacks.picker.buffers()
  else
    vim.cmd("buffers")
  end
end, { desc = "Find Buffers" })

pcall(vim.keymap.del, "n", "<leader>-")
pcall(vim.keymap.del, "n", "<leader>|")
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>uw", ":set wrap!<CR>", { desc = "Toggle wrap" })
vim.keymap.set("n", "<leader>r", "<cmd>checktime<cr>", { desc = "Reload changed files" })

vim.keymap.set("n", "<leader>th", function()
  vim.cmd("botright split")
  vim.cmd("terminal")
  vim.cmd("wincmd J")
  vim.cmd("startinsert")
end, { desc = "Terminal Horizontal" })

vim.keymap.set("n", "<leader>tv", function()
  vim.cmd("vsplit")
  vim.cmd("terminal")
  vim.cmd("startinsert")
end, { desc = "Terminal Vertical" })

local function switch_to_other_buffer()
  local alt = vim.fn.bufnr("#")
  if alt <= 0 or not vim.api.nvim_buf_is_valid(alt) then
    vim.notify("Aucun buffer alternatif", vim.log.levels.WARN)
    return
  end

  vim.cmd("buffer " .. alt)
end

vim.keymap.set("n", "<leader>bb", switch_to_other_buffer, { desc = "Switch to Other Buffer" })
pcall(vim.keymap.del, "n", "<leader>`")

local function toggle_termux_notes()
  local path = vim.fn.expand("~/dotfiles/nvim/MyNeovimTermux/README-TERMUX.md")
  if vim.fn.filereadable(path) == 0 then
    vim.notify("README-TERMUX.md introuvable", vim.log.levels.WARN)
    return
  end

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

  vim.keymap.set("n", "q", close_and_return, { buffer = true, desc = "Fermer notes Termux" })
  vim.keymap.set("n", "<leader>bd", close_and_return, { buffer = true, desc = "Fermer notes Termux" })
  vim.keymap.set("n", "<leader>wd", close_and_return, { buffer = true, desc = "Fermer notes Termux" })
end

vim.keymap.set("n", "<leader>H", toggle_termux_notes, { desc = "Termux Notes" })

require("shipglowz").setup()

pcall(vim.keymap.del, "n", "<leader>L")

-- Explicit mouse wheel scroll, useful in Termux and remote shells.
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelUp>", "3<C-y>", { desc = "Scroll up" })
vim.keymap.set({ "n", "v", "x" }, "<ScrollWheelDown>", "3<C-e>", { desc = "Scroll down" })
vim.keymap.set("i", "<ScrollWheelUp>", "<C-o>3<C-y>", { desc = "Scroll up" })
vim.keymap.set("i", "<ScrollWheelDown>", "<C-o>3<C-e>", { desc = "Scroll down" })

local function copy_to_clipboard(text)
  local b64 = vim.base64.encode(text)
  local osc52 = string.format("\027]52;c;%s\027\\", b64)
  io.stdout:write(osc52)

  local f = io.open("/tmp/nvim_notif.txt", "w")
  if f then
    f:write(text)
    f:close()
  end
end

vim.keymap.set("n", "<leader>nn", function()
  local ok = pcall(vim.cmd, "Noice history")
  if not ok then
    vim.notify("Noice indisponible", vim.log.levels.WARN)
  end
end, { desc = "Afficher notifications" })

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

local function get_front_matter_end()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if lines[1] ~= "---" then
    return nil
  end

  for lnum = 2, #lines do
    if lines[lnum] == "---" then
      return lnum
    end
  end

  return nil
end

function _G.__termux_fm_foldexpr(lnum)
  local end_fm = vim.b.front_matter_end_line
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  local prev_expr = vim.b.fm_prev_foldexpr

  local function fallback_fold_expr()
    if prev_expr and prev_expr ~= "" and prev_expr ~= "v:lua.__termux_fm_foldexpr(v:lnum)" then
      vim.v.lnum = lnum
      local ok, res = pcall(vim.api.nvim_eval, prev_expr)
      if ok and res ~= nil then
        return res
      end
    end
    if vim.treesitter and vim.treesitter.foldexpr then
      vim.v.lnum = lnum
      local ok, res = pcall(vim.treesitter.foldexpr)
      return ok and res or "="
    end
    return "="
  end

  if first_line ~= "---" or not end_fm then
    return fallback_fold_expr()
  end

  if lnum == 1 then
    return "a1"
  elseif lnum < end_fm then
    return "1"
  elseif lnum == end_fm then
    return "s1"
  end

  return fallback_fold_expr()
end

local function fold_front_matter()
  local end_fm = get_front_matter_end()
  vim.b.front_matter_end_line = end_fm
  vim.b.fm_prev_foldexpr = vim.wo.foldexpr

  if not end_fm then
    vim.notify("Pas de front matter détectable (--- ... ---) en tête de fichier", vim.log.levels.INFO)
    return
  end

  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.__termux_fm_foldexpr(v:lnum)"

  local cur = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  if vim.fn.foldclosed(1) == 1 then
    vim.cmd("normal! zo")
  else
    vim.cmd("normal! zc")
  end

  vim.api.nvim_win_set_cursor(0, cur)
end

vim.api.nvim_create_user_command("FoldFrontMatter", fold_front_matter, {
  desc = "Toggle fold front matter (--- ... ---)",
})

pcall(vim.keymap.del, "n", "zF")
vim.keymap.set("n", "zF", "<cmd>FoldFrontMatter<cr>", {
  desc = "Fold front matter",
  silent = true,
  nowait = true,
})
