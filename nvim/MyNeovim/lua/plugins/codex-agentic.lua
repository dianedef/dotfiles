local function normalize_dir(path)
  if not path or path == "" then
    return nil
  end

  local normalized = vim.fs.normalize(vim.fn.expand(path))
  if vim.fn.isdirectory(normalized) == 0 then
    return nil
  end

  return normalized
end

local function resolve_codex_acp_command()
  local local_bin = vim.fn.expand("~/.npm-global/bin/codex-acp")
  if vim.fn.executable(local_bin) == 1 then
    return local_bin
  end

  return "codex-acp"
end

local function resolve_neotree_path()
  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if not ok or not manager.get_state then
    return nil
  end

  local state = manager.get_state("filesystem")
  if not state or not state.tree then
    return nil
  end

  local ok_node, node = pcall(function()
    return state.tree:get_node()
  end)
  if not ok_node or not node then
    return nil
  end

  local path = node.path or (node.get_id and node:get_id()) or node.id
  if not path then
    return nil
  end

  if vim.fn.isdirectory(path) == 1 then
    return normalize_dir(path)
  end

  return normalize_dir(vim.fn.fnamemodify(path, ":h"))
end

local function resolve_cwd_from_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end

  local absolute = vim.fn.expand(name)
  if vim.fn.filereadable(absolute) == 1 then
    return normalize_dir(vim.fn.fnamemodify(absolute, ":h"))
  end

  return nil
end

local function resolve_codex_cwd()
  return normalize_dir(resolve_neotree_path())
    or resolve_cwd_from_file()
    or normalize_dir(vim.fn.getcwd())
end

local function get_tab_session_cwd(tab)
  local cwd = vim.t[tab].agentic_codex_session_cwd
  if cwd and cwd ~= "" then
    return normalize_dir(cwd)
  end
end

local function set_tab_session_cwd(tab, cwd)
  if cwd and cwd ~= "" then
    vim.t[tab].agentic_codex_session_cwd = cwd
    return
  end
  vim.t[tab].agentic_codex_session_cwd = nil
end

local function sync_codex_session_cwd()
  local tab = vim.api.nvim_get_current_tabpage()
  local cwd = resolve_codex_cwd()
  if cwd then
    set_tab_session_cwd(tab, cwd)
  end
  return get_tab_session_cwd(tab)
end

local function codex_statusline()
  local tab = vim.api.nvim_win_get_tabpage(0)
  local cwd = get_tab_session_cwd(tab) or normalize_dir(vim.fn.getcwd())
  if not cwd then
    return "Codex"
  end

  return "󰻞 Codex: " .. vim.fn.fnamemodify(cwd, ":~")
end

_G.__agentic_codex_statusline = codex_statusline

local AGENTIC_FILETYPES = {
  "AgenticChat",
  "AgenticInput",
  "AgenticCode",
  "AgenticFiles",
  "AgenticDiagnostics",
  "AgenticTodos",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = AGENTIC_FILETYPES,
  callback = function()
    vim.wo.statusline = "%{%v:lua.__agentic_codex_statusline()%}"
  end,
})

local function run_codex_new_session_in_dir()
  local target_cwd = resolve_codex_cwd()
  if not target_cwd then
    sync_codex_session_cwd()
    require("agentic").new_session()
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  set_tab_session_cwd(tab, target_cwd)

  local previous_cwd = vim.fn.getcwd()
  vim.fn.chdir(target_cwd)
  require("agentic").new_session()
  vim.schedule(function()
    if vim.fn.getcwd() ~= previous_cwd then
      vim.fn.chdir(previous_cwd)
    end
  end)
end

return {
  {
    "carlos-algms/agentic.nvim",
    enabled = true,
    opts = {
      provider = "codex-acp",
      acp_providers = {
        ["codex-acp"] = {
          name = "Codex ACP",
          command = resolve_codex_acp_command(),
          env = {},
        },
      },
      windows = {
        position = "bottom",
        width = "100%",
        height = "42%",
        stack_width_ratio = 0.5,
        input = { height = 8 },
        code = { max_height = 18 },
        files = { max_height = 12 },
        diagnostics = { max_height = 10 },
        todos = { display = true, max_height = 10 },
      },
      diff_preview = {
        enabled = true,
        layout = "split",
        center_on_navigate_hunks = true,
      },
      settings = {
        move_cursor_to_chat_on_submit = true,
      },
      headers = {
        chat = function(parts)
          local tab = vim.api.nvim_get_current_tabpage()
          local cwd = vim.t[tab].agentic_codex_session_cwd
          if cwd and cwd ~= "" then
            parts.context = "cwd: " .. vim.fn.fnamemodify(cwd, ":~")
          end
          local text = parts.title
          if parts.context then
            text = text .. " | " .. parts.context
          end
          if parts.suffix then
            text = text .. " | " .. parts.suffix
          end
          return text
        end,
      },
    },
  keys = {
      {
        "<leader>ajt",
        function()
          sync_codex_session_cwd()
          require("agentic").toggle()
        end,
        mode = { "n", "v" },
        desc = "Agentic Toggle",
      },
      {
        "<leader>ajf",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Agentic Add File/Selection",
      },
      {
        "<leader>ajn",
        function()
          run_codex_new_session_in_dir()
        end,
        mode = { "n", "v" },
        desc = "Agentic New Session (context cwd)",
      },
      {
        "<leader>ajr",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v" },
        desc = "Agentic Restore Session",
      },
      {
        "<leader>ajl",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = { "n" },
        desc = "Agentic Add Line Diagnostics",
      },
      {
        "<leader>ajb",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = { "n" },
        desc = "Agentic Add Buffer Diagnostics",
      },
      {
        "<leader>akt",
        function()
          sync_codex_session_cwd()
          require("agentic").toggle()
        end,
        mode = { "n", "v" },
        desc = "Codex Toggle",
      },
      {
        "<leader>akf",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Codex Add File/Selection",
      },
      {
        "<leader>akn",
        function()
          run_codex_new_session_in_dir()
        end,
        mode = { "n", "v" },
        desc = "Codex New Session (context cwd)",
      },
      {
        "<leader>akr",
        function()
          require("agentic").restore_session()
        end,
        mode = { "n", "v" },
        desc = "Codex Restore Session",
      },
      {
        "<leader>akl",
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        mode = { "n" },
        desc = "Codex Add Line Diagnostics",
      },
      {
        "<leader>akb",
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        mode = { "n" },
        desc = "Codex Add Buffer Diagnostics",
      },
    },
  },
}
