local builtin = require 'telescope.builtin'

return {
  -- Scratch Keybinds
  vim.keymap.set('n', '<leader><leader>sn', '<cmd>Scratch<cr>', { desc = 'Create a new scratch file' }),
  vim.keymap.set('n', '<leader><leader>so', '<cmd>ScratchOpen<cr>', { desc = 'Open scratch file explorer' }),

  -- VimTest
  vim.keymap.set('n', '<leader>tf', ':TestFile<CR>', { noremap = false }),
  vim.keymap.set('n', '<leader>tn', ':TestNearest<CR>', { noremap = false }),

  -- Telescope Bookmarks

  vim.keymap.set('n', '<leader>sg ', builtin.marks, { desc = '[S]earch [M]arks', noremap = false }),

  -- Telescope Todo
  vim.keymap.set('n', '<leader>st', ':TodoTelescope<CR>', { desc = '[S]earch [T]odo', noremap = false }),

  -- Preview
  vim.keymap.set('n', '<leader>p', function()
    if vim.bo.filetype == 'markdown' then
      vim.cmd 'MarkdownPreview'
    else
      print 'File does not support preview'
    end
  end, { noremap = false }),

  -- Git Conflict
  vim.keymap.set('n', '<leader>x', ':GitConflictListQf<CR>', { desc = 'List Conflicts', noremap = false }),

  -- Harpoon
  vim.keymap.set('n', '<leader>hl', ':Telescope harpoon marks<CR>', { desc = '[H]arpoon [L]ist Marks', noremap = false }),
  vim.keymap.set('n', '<leader>hm', function()
    require('harpoon.mark').add_file()
  end, { desc = '[H]arpoon [M]ark file', noremap = false }),
  vim.keymap.set('n', '<leader>hr', function()
    require('harpoon.mark').rm_file()
  end, { desc = '[H]arpoon [M]ark file', noremap = false }),

  -- Neotree
  vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { desc = '[N]eotree Toggle', noremap = false }),
}
