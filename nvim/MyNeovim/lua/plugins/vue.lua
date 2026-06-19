return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vue_ls = {},
        vtsls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "vue", "css" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vue_ls = vim.tbl_deep_extend("force", opts.servers.vue_ls or {}, {
        mason = false,
        enabled = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local function resolve_vue_ts_plugin_path()
        local candidates = {}
        local ok, registry = pcall(require, "mason-registry")
        if ok and registry.has_package("vue-language-server") then
          local pkg = registry.get_package("vue-language-server")
          local install_path = pkg:get_install_path()
          if install_path and install_path ~= "" then
            candidates[#candidates + 1] = install_path .. "/node_modules/@vue/language-server"
            candidates[#candidates + 1] = install_path .. "/node_modules/@vue/typescript-plugin"
          end
        end

        candidates[#candidates + 1] = vim.fn.stdpath("data")
          .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
        candidates[#candidates + 1] = vim.fn.stdpath("data")
          .. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin"

        for _, path in ipairs(candidates) do
          if vim.uv.fs_stat(path) then
            return path
          end
        end
      end

      local plugin_path = resolve_vue_ts_plugin_path()
      if not plugin_path then
        return
      end

      opts.servers = opts.servers or {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      opts.servers.vtsls.filetypes = opts.servers.vtsls.filetypes or {}

      if not vim.tbl_contains(opts.servers.vtsls.filetypes, "vue") then
        table.insert(opts.servers.vtsls.filetypes, "vue")
      end

      LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@vue/typescript-plugin",
          location = plugin_path,
          languages = { "vue" },
          configNamespace = "typescript",
          enableForWorkspaceTypeScriptVersions = true,
        },
      })
    end,
  },
}
