return {
  "kdheepak/lazygit.nvim",
  enabled = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gf", "<cmd>LazyGitFilter<cr>", desc = "LazyGit Filter" },
    { "<leader>gF", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "LazyGit Filter Current File" },
  },
  init = function()
    local home = os.getenv("HOME") or ""
    local config_dir = home .. "/.config/lazygit"
    local user_config = config_dir .. "/config.yml"
    local dotfiles_config = home .. "/dotfiles/lazygit/config.yml"

    vim.g.lazygit_floating_window_winblend = 0 -- transparency
    vim.g.lazygit_floating_window_scaling_factor = 0.95
    vim.g.lazygit_floating_window_use_plenary = 0 -- double border for some reason
    vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

    if vim.uv.fs_stat(user_config) then
      vim.g.lazygit_use_custom_config_file_path = 1
      vim.g.lazygit_config_file_path = user_config
    elseif vim.uv.fs_stat(dotfiles_config) then
      vim.g.lazygit_use_custom_config_file_path = 1
      vim.g.lazygit_config_file_path = dotfiles_config
    else
      vim.g.lazygit_use_custom_config_file_path = 0
    end
  end,
}
