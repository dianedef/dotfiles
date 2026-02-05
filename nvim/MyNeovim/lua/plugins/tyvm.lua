return {
  "zackradisic/tyvm",
  build = "cargo build --release",
  ft = { "typescript", "typescriptreact" },
  keys = {
    { "<leader>ct", "<cmd>Tyvm<cr>", desc = "Tyvm - Visualize TypeScript types" },
  },
}
