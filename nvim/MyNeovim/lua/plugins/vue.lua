return {
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
      local ok, registry = pcall(require, "mason-registry")
      if not ok then
        return
      end

      local has_vue_ls = registry.has_package("vue-language-server")
      if not has_vue_ls then
        return
      end

      local pkg = registry.get_package("vue-language-server")
      local install_path = pkg:get_install_path()
      if not install_path or install_path == "" then
        return
      end

      local plugin_path = install_path .. "/node_modules/@vue/language-server"
      if vim.uv.fs_stat(plugin_path) == nil then
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
