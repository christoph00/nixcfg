local create_autocmd = vim.api.nvim_create_autocmd


-- Highlight on yank
create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})


-- Close some filetypes with <q>
create_autocmd("FileType", {
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
    "dbout",
    "dap-float"
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Change CWD to opened directory
create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
    end
  end
})


-- Enable iwe on Markdown
create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    vim.lsp.start({
      name = 'iwes',
      cmd = {'iwes'},
      root_dir = vim.fs.root(args.buf, {'.iwe' }),
      flags = {
        debounce_text_changes = 500
      }
    })
  end,
})
