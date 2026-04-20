return {
  "kevinhwang91/nvim-ufo",
  enabled = true,
  event = "VeryLazy",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  opts = {
    provider_selector = function(_, filetype, _)
      -- Treesitter pour markdown (fold les headings)
      if filetype == "markdown" then
        return { "treesitter", "indent" }
      end
      return { "lsp", "indent" }
    end,
    preview = {
      win_config = {
        winblend = 0,
        maxheight = 99,
      },
      mappings = {
        scrollU = "<C-b>",
        scrollD = "<C-f>",
        jumpTop = "[",
        jumpBot = "]",
      },
    },
    -- adding folded line number instead of "..."
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d "):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          -- str width returned from truncate() may less than 2nd argument, need padding
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
  keys = {
    { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
    { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open more folds" },
    { "zm", function() vim.cmd("normal! zm") end, desc = "Close more folds" },
    { "K", function() local ok, ufo = pcall(require, "ufo"); if ok and ufo.peekFoldedLinesUnderCursor() then return end; vim.lsp.buf.hover() end, desc = "Peek fold or hover" },
  },
}
