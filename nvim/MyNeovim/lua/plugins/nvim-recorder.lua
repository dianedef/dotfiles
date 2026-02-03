return {
  "chrisgrieser/nvim-recorder",
  enabled = false,
  dependencies = { "rcarriga/nvim-notify" },
  opts = {
    slots = { "a", "b" },
    mapping = {
      startStopRecording = "q",
      playMacro = "Q",
      switchSlot = "<C-q>",
      editMacro = "cq",
      deleteAllMacros = "dq",
      yankMacro = "yq",
    },
  },
}
