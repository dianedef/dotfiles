local test_path = debug.getinfo(1, "S").source:sub(2)
local myneovim_root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(test_path)))
local config_path = vim.fs.joinpath(myneovim_root, "lua", "plugins", "avante.lua")
local spec = assert(loadfile(config_path))()
local provider = assert(spec.opts.acp_providers.codex)
local command = assert(provider.command)
local normalized_command = command:gsub("\\", "/")

assert(vim.fn.executable(command) == 1, "Codex ACP command is not executable: " .. command)
assert(
  normalized_command:match("/node_modules/@zed%-industries/codex%-acp%-[^/]+/bin/codex%-acp%.?e?x?e?$") ~= nil,
  "Avante must launch the native Codex ACP binary directly, got: " .. command
)

local uv = vim.uv or vim.loop
local stdin = assert(uv.new_pipe(false))
local stdout = assert(uv.new_pipe(false))
local stderr = assert(uv.new_pipe(false))
local exited = false
local exit_code
local exit_signal
local handle
local pid

local function close_pipe(pipe)
  if pipe and not pipe:is_closing() then
    pipe:close()
  end
end

handle, pid = uv.spawn(command, {
  args = provider.args,
  env = nil,
  stdio = { stdin, stdout, stderr },
}, function(code, signal)
  exit_code = code
  exit_signal = signal
  exited = true
  close_pipe(stdin)
  close_pipe(stdout)
  close_pipe(stderr)
  if handle and not handle:is_closing() then
    handle:close()
  end
end)

assert(handle and pid, "Failed to launch native Codex ACP")
vim.wait(250)
pcall(function() handle:kill(15) end)
pcall(function() handle:kill(9) end)
assert(vim.wait(5000, function() return exited end, 25), "Codex ACP did not stop within five seconds")
if uv.os_uname().sysname == "Linux" then
  assert(uv.fs_stat("/proc/" .. pid) == nil, "Codex ACP process still exists after stop: " .. pid)
end

print(string.format("codex-acp lifecycle passed: pid=%d code=%s signal=%s", pid, exit_code, exit_signal))
