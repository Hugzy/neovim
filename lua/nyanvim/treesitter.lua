require('lze').load {
  {
    'nvim-treesitter',
    event = 'DeferredUIEnter',
    dep_of = { 'render-markdown.nvim' },
    load = function(name)
      require('lzextras').loaders.multi {
        name,
        'nvim-treesitter-textobjects',
        'treesitter-context',
        'nvim-ts-autotag',
      }
    end,
    after = function(_)
      -- main-branch nvim-treesitter no longer configures highlighting itself.
      -- Parsers are provided by nix (withAllGrammars); enable highlighting per-buffer.
      local group = vim.api.nvim_create_augroup('nyanvim_treesitter', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          pcall(vim.treesitter.start, buf)
        end
      end

      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local select_keymaps = {
        ['af'] = '@function.outer', -- function
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer', -- class
        ['ic'] = '@class.inner',
        ['al'] = '@loop.outer', -- loop
        ['il'] = '@loop.inner',
        ['as'] = '@conditional.outer', -- conditionals
        ['is'] = '@conditional.inner',
      }
      for lhs, obj in pairs(select_keymaps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(obj, 'textobjects')
        end)
      end

      local move = require 'nvim-treesitter-textobjects.move'
      local move_keymaps = {
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
          [']l'] = '@loop.outer',
          [']s'] = '@conditional.outer',
          [']p'] = '@parameter.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
          [']L'] = '@loop.outer',
          [']S'] = '@conditional.outer',
          [']P'] = '@parameter.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
          ['[l'] = '@loop.outer',
          ['[s'] = '@conditional.outer',
          ['[p'] = '@parameter.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
          ['[L'] = '@loop.outer',
          ['[S'] = '@conditional.outer',
          ['[P'] = '@parameter.outer',
        },
      }
      for fn, keymaps in pairs(move_keymaps) do
        for lhs, obj in pairs(keymaps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](obj, 'textobjects')
          end)
        end
      end

      local swap = require 'nvim-treesitter-textobjects.swap'
      vim.keymap.set('n', 'gpl', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', 'gph', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap previous parameter' })

      require('treesitter-context').setup {
        enable = true,
        max_lines = 0,
        mode = 'topline',
        separator = '-',
      }
      require('nvim-ts-autotag').setup {
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      }
    end,
  },
}
