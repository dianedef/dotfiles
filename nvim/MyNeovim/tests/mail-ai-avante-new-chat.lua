local test_path = debug.getinfo(1, "S").source:sub(2)
local myneovim_root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(test_path)))
package.path = table.concat({
  vim.fs.joinpath(myneovim_root, "lua", "?.lua"),
  vim.fs.joinpath(myneovim_root, "lua", "?", "init.lua"),
  package.path,
}, ";")

local captured

package.loaded["shipglows.mail.config"] = {
  get = function()
    return {
      ai_provider = "avante",
      ai_model_provider = "codex",
      project_index_root = vim.fs.joinpath(vim.fn.stdpath("cache"), "mail-ai-empty-project-index"),
    }
  end,
}
package.loaded["avante.api"] = {
  ask = function(opts) captured = opts end,
}
package.loaded["shipglows.mail.ai"] = nil

local ai = require("shipglows.mail.ai")
assert(ai.ask("Classe cette source", "source de test"))
assert(captured, "Mail Intelligence did not call Avante")
assert(captured.provider == "codex", "Mail Intelligence did not preserve the configured ACP provider")
assert(captured.new_chat == true, "Each Mail Intelligence analysis must start a fresh ACP session")

print("mail-ai Avante new-chat contract passed")
