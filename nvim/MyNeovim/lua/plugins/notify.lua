return {
  "rcarriga/nvim-notify",
  enabled = true,
  config = function()
    require("notify").setup({
      timeout = 1200,
      background_colour = "#000000",
    })
    local banned_patterns = { "removed %d+ missing entries." }
    vim.notify = function(msg, ...)
      for _, pattern in ipairs(banned_patterns) do
        if string.match(msg, pattern) then
          return
        end
      end
      require("notify")(msg, ...)
    end
  end,
}
