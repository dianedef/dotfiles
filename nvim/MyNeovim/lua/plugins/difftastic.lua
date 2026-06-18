local function open_difftastic()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Difftastic requires a file-backed buffer", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, ".git")
  if not root then
    vim.notify("Difftastic requires a git repository", vim.log.levels.WARN)
    return
  end

  local relpath = file:sub(#root + 2)
  if relpath == "" then
    vim.notify("Unable to resolve file path relative to git root", vim.log.levels.WARN)
    return
  end

  local head = vim.system({ "git", "-C", root, "show", ("HEAD:%s"):format(relpath) }, { text = true }):wait()
  if head.code ~= 0 then
    vim.notify(("Unable to read HEAD version for %s"):format(relpath), vim.log.levels.WARN)
    return
  end

  local tmp = vim.fn.tempname()
  vim.fn.writefile(vim.split(head.stdout or "", "\n", { plain = true }), tmp)

  vim.cmd("botright split")
  vim.cmd(("terminal difft --color=always %s %s"):format(vim.fn.shellescape(tmp), vim.fn.shellescape(file)))
  vim.cmd("startinsert")
end

return {
  name = "difftastic-config",
  dir = vim.fn.stdpath("config"),
  virtual = true,
  enabled = true,
  init = function()
    vim.api.nvim_create_user_command("Difftastic", open_difftastic, {})
    vim.keymap.set("n", "<leader>gd", open_difftastic, { desc = "Difftastic diff current file" })
  end,
}
