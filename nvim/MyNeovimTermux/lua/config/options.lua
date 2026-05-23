-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.wrap = true
vim.opt.linebreak = true

-- Android/Termux editing is mostly touch + soft keyboard, so keep mouse support on.
vim.opt.mouse = "a"
vim.opt.mousescroll = "ver:3,hor:6"

-- Prevent E35 "No previous regular expression" when plugins call n/N before any search.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.getreg("/") == "" then
      vim.fn.setreg("/", "\\%^")
    end
  end,
})

vim.opt.sessionoptions = {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize",
  "winpos",
  "terminal",
}

vim.opt.spell = false
vim.opt.spelllang = "fr,en_us"
