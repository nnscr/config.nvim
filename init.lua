-- flickering workaround
vim.g._ts_force_sync_parsing = true
vim.diagnostic.config {
  virtual_text = true,
  -- virtual_lines = true,
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Enable custom colored cursor
vim.opt.termguicolors = true -- true color mode
vim.opt.guicursor = { -- use custom group
  'n-v-c:block-Cursor', -- normal/visual/command: block, hl=Cursor
  'i:ver25-CursorInsert',
}

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- disable timeout for leader key
vim.opt.timeout = false

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
-- vim.opt.listchars = { tab = '» ', trail = ' ', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 20

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- Show a visual line on column 120
vim.opt.colorcolumn = '120'
vim.opt.termguicolors = true
vim.opt.textwidth = 0

-- enable spell checking
vim.opt.spell = true
vim.opt.spelllang = 'en_us,de_de'
vim.opt.spelloptions = 'camel,noplainbuffer'

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- disable comment continuation on new lines for php files (if will still work for all comments, but stops
-- adding comments after attributes because the default formatter thing thinks it's a comment)
vim.g.PHP_autoformatcomment = 0

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>j', vim.diagnostic.goto_next, { desc = 'Go to next Diagnostic message' })
vim.keymap.set('n', '<leader>k', vim.diagnostic.goto_prev, { desc = 'Go to previous Diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [d]iagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [d]iagnostic [Q]uickfix list' })

-- varsity specific key binds
local varsity = require 'custom.projects.varsity'
vim.keymap.set('n', '<leader>tf', varsity.CopyTranslationFilePrefix, { desc = '[t]ranslation yank [f]ile name' })
vim.keymap.set('n', '<leader>ty', varsity.CopyTranslationKeyUnderCursor, { desc = '[t]ranslation [y]ank key path' })
vim.keymap.set('n', '<leader>tY', varsity.CopyTranslationKeyUnderCursorWithCall, { desc = '[t]ranslation [Y]ank key path with call' })
vim.keymap.set('n', '<leader>tu', ':split<CR>:term just t<CR>G', { desc = '[t]ranslation [u]pdate' })
vim.keymap.set('n', '<leader>*', '*:%s//')
vim.keymap.set('v', '<leader>*', 'y/\\V<C-R><CR><CR>:%s//')

-- <leader>nt = <div></div> -> <div>\n|\n</div>
function surround_html_with_newlines()
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Match any HTML tag in the form of <tag attributes>...</tag>
  local tag_pattern = '^%s*<(%w+)(.-)>(.-)</%1>%s*$'

  -- Find the matching tag, attributes, and content inside
  local opening_tag, attributes, content = line:match(tag_pattern)

  if not opening_tag then
    print 'No valid HTML tag found on this line.'
  end

  -- Detect whether the current line uses tabs or spaces for indentation
  local indent = string.match(line, '^%s*') -- Capture current indentation
  local use_tabs = indent:find '\t' ~= nil -- Check if indentation uses tabs

  -- Set the appropriate indentation: either a tab or four spaces
  local indent_unit = use_tabs and '\t' or '    '
  local content_indent = indent .. indent_unit -- Add one more level of indentation

  local updated_lines = {}

  -- Check if the content is empty (i.e., <div></div>)
  if content == '' then
    -- Insert the new formatted tag structure for empty content
    updated_lines = {
      indent .. '<' .. opening_tag .. attributes .. '>',
      content_indent, -- One depth indentation for new content
      indent .. '</' .. opening_tag .. '>',
    }
  else
    -- Insert the new formatted tag structure for non-empty content
    updated_lines = {
      indent .. '<' .. opening_tag .. attributes .. '>',
      content_indent, -- One depth indentation for new content
      content_indent .. vim.trim(content), -- Existing content indented at one level deeper
      indent .. '</' .. opening_tag .. '>',
    }
  end

  -- Replace the current line with the new lines
  vim.api.nvim_buf_set_lines(0, cursor_pos[1] - 1, cursor_pos[1], false, updated_lines)

  -- Move the cursor to the indented blank line inside the tag
  vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, #content_indent })

  vim.cmd 'startinsert!' -- Enter insert mode automatically
end

-- vim.keymap.set('n', '<leader>nt', 'vit<ESC>i<CR><ESC>O', { desc = 'insert break in tag' })
vim.keymap.set('n', '<leader>nt', surround_html_with_newlines, { desc = 'insert break in tag' })
-- move rest of the line to new line and wrap in curly braces
-- original: if (true) return null
-- after:    if (true) {
--               return null;
--           }
vim.keymap.set('n', '<leader>nb', 'i{<ENTER><ESC>$o}<ESC>', { desc = 'insert break in block' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = '[Y]ank to clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = '[Y]ank to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"*p', { desc = '[P]aste from clipboard' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-j>', ':cnext<CR>', { desc = 'Move to the next item in the quickfix list' })
vim.keymap.set('n', '<C-k>', ':cprev<CR>', { desc = 'Move to the previous item in the quickfix list' })

-- ,h, ,l, ,j, ,k to switch between windows
vim.keymap.set('n', ',h', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', ',l', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', ',j', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', ',k', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- , arrow keys to switch between windows
vim.keymap.set('n', ',<left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', ',<right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', ',<down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', ',<up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- increase / decrease split size with ctrl + arrow keys
vim.keymap.set('n', '<C-Up>', '<CMD>resize +2<CR>', { desc = 'Increase split size' })
vim.keymap.set('n', '<C-Down>', '<CMD>resize -2<CR>', { desc = 'Decrease split size' })
vim.keymap.set('n', '<C-Left>', '<CMD>vertical resize +2<CR>', { desc = 'Increase vertical split size' })
vim.keymap.set('n', '<C-Right>', '<CMD>vertical resize -2<CR>', { desc = 'Decrease vertical split size' })

-- increase / decrease split size with alt + arrow keys
vim.keymap.set('n', '<A-Up>', '<CMD>resize +2<CR>', { desc = 'Increase split size' })
vim.keymap.set('n', '<A-Down>', '<CMD>resize -2<CR>', { desc = 'Decrease split size' })
vim.keymap.set('n', '<A-Left>', '<CMD>vertical resize +2<CR>', { desc = 'Increase vertical split size' })
vim.keymap.set('n', '<A-Right>', '<CMD>vertical resize -2<CR>', { desc = 'Decrease vertical split size' })

-- delete to black hole register
vim.keymap.set({ 'n', 'v' }, ',d', '"_d', { desc = 'Delete to black hole register' })
vim.keymap.set({ 'n', 'v' }, ',x', '"_x', { desc = 'X to black hole register' })
vim.keymap.set({ 'n', 'v' }, ',c', '"_c', { desc = 'Change to black hole register' })

-- vim.keymap.set('n', '<leader>e', function()
--   if vim.api.nvim_buf_get_option(0, 'filetype') == 'netrw' then
--     vim.api.nvim_exec(':bd', false)
--   else
--     vim.api.nvim_exec(':Ex', false)
--   end
-- end, { desc = '[E]xplorer (netrw)' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Set terminal buffer options',
  group = vim.api.nvim_create_augroup('kickstart-termopen', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.spell = false
  end,
})

-- make :gp alias for :Git push
vim.cmd [[cnoreabbrev gp Git push]]

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)
      vim.keymap.set('n', '<leader>gj', require('gitsigns').next_hunk, { desc = 'Next Git Sign' })
      vim.keymap.set('n', '<leader>gk', require('gitsigns').prev_hunk, { desc = 'Previous Git Sign' })
      vim.keymap.set('n', '<leader>gq', require('gitsigns').setqflist, { desc = 'Previous Git Sign' })
      vim.keymap.set('n', '<leader>gd', require('gitsigns').toggle_deleted, { desc = 'Toggle [d]eleted lines' })
      vim.keymap.set('n', '<leader>hs', require('gitsigns').reset_hunk, { desc = '[h]uren [s]ohn' })
    end,
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]ranslations' },
        { '<leader>g', group = '[G]it and Copilot' },
        { '<leader><leader>', hidden = true },
        { '<leader>0', hidden = true },
        { '<leader>1', hidden = true },
        { '<leader>2', hidden = true },
        { '<leader>3', hidden = true },
        { '<leader>4', hidden = true },
        { '<leader>5', hidden = true },
        { '<leader>6', hidden = true },
        { '<leader>7', hidden = true },
        { '<leader>8', hidden = true },
        { '<leader>9', hidden = true },
        { '<leader>a', desc = '[a]dd to harpoon' },
        { '<leader>A', desc = '[A]dd and open harpoon' },
      }
    end,
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = '^1.0.0',
      },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        pickers = {
          colorscheme = {
            enable_preview = true,
          },
          buffers = { sorting_strategy = 'ascending' },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'live_grep_args')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local extensions = require('telescope').extensions

      local find_files = function()
        builtin.find_files {
          hidden = true,
        }
      end

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sF', find_files, { desc = '[S]earch All [F]iles' })
      vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = '[S]earch Git [F]iles' })
      -- vim.keymap.set('n', '<leader><leader>', find_files, { desc = '[S]earch Git [F]iles' })
      vim.keymap.set('n', '<leader>sa', function()
        -- find all files, even ones ignored by .gitignore
        builtin.find_files { no_ignore = true, hidden = true }
      end, { desc = '[S]earch [a]ll Files' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sG', extensions.live_grep_args.live_grep_args, { desc = '[S]earch by [G]rep with args' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Find existing [b]uffers' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = 'Find [c]ommands' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = true,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', '<leader>sv', function()
        -- find .vue files only
        builtin.find_files {
          hidden = true,
          find_command = { 'rg', '--files', '--glob', '*.vue' },
        }
      end, { desc = '[S]earch [V]ue Files' })
    end,
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      -- replaced by lazydev
      -- { 'folke/neodev.nvim', opts = {} },
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
          library = {
            '~/.config/nvim',
          },
        },
      },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('gy', require('telescope.builtin').lsp_type_definitions, '[G]oto T[y]pe Definition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- organize imports for tsserver (typescript-tools uses :TSToolsOrganizeImports)
          -- map('<leader>co', '<CMD>OrganizeImports<CR>', '[C]ode [O]rganize Imports')
          -- in deinem LspAttach-Autocmd:
          map('<leader>co', function()
            -- vtsls / tsserver liefert eines dieser Action-Kinds zurück
            vim.lsp.buf.code_action {
              context = {
                only = {
                  'source.organizeImports', -- generisch
                  'source.organizeImports.ts', -- TS / TSX
                  'source.organizeImports.js', -- JS / JSX
                },
                diagnostics = {}, -- leer lassen -> ganze Datei
              },
              apply = true, -- erste gefundene Aktion automatisch ausführen
            }
          end, '[C]ode [O]rganize Imports')
          -- map('<leader>co', ':TSToolsOrganizeImports<CR>', '[C]ode [O]rganize Imports')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('<leader>cx', ':EslintFixAll<CR>', '[C]ode Fi[x] all')
          -- vim.keymap.set('i', '<C-.>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })
          -- vim.keymap.set('n', '<C-.>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --
      local function organize_imports()
        local params = {
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(0) },
          title = '',
        }
        vim.lsp.buf.execute_command(params)
      end

      local vue_plugin = {
        name = '@vue/typescript-plugin',
        location = '/opt/homebrew/lib/node_modules/@vue/typescript-plugin/',
        languages = { 'vue' },
        configNamespace = 'typescript',
      }
      local vtsls_config = {
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
        settings = {
          vtsls = {
            experimental = { vue = { plugin = true } },
            tsserver = {
              path = '/opt/homebrew/lib/node_modules/typescript/lib',
              globalPlugins = {
                vue_plugin,
              },
            },
          },
        },
        on_attach = function()
          vim.keymap.set('n', '<leader>vg', function()
            -- Get component name from file name (e.g. MyComponent.vue -> "MyComponent")
            local comp_name = vim.fn.expand '%:t:r'
            local rg_cmd = 'rg --vimgrep "\\b' .. comp_name .. '\\b"'
            local results = vim.fn.systemlist(rg_cmd)

            if vim.tbl_isempty(results) then
              vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
              return
            end

            require('telescope.builtin').live_grep { default_text = comp_name }
          end, { desc = '[V]ue grep component name' })
          vim.keymap.set('n', '<leader>vv', function()
            -- Get the component name from the file's basename (e.g. MyComponent.vue → "MyComponent")
            local comp_name = vim.fn.expand '%:t:r'

            vim.lsp.buf_request(0, 'workspace/symbol', { query = comp_name }, function(err, result)
              if err then
                vim.notify('Error: ' .. err.message, vim.log.levels.ERROR)
                return
              end

              if not result or vim.tbl_isempty(result) then
                vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
                return
              end

              -- Filter to include only symbols that have a valid location.
              local symbols = {}
              for _, sym in ipairs(result) do
                if sym.location then
                  table.insert(symbols, sym)
                end
              end

              if vim.tbl_isempty(symbols) then
                vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
                return
              end

              local pickers = require 'telescope.pickers'
              local finders = require 'telescope.finders'
              local conf = require('telescope.config').values
              local actions = require 'telescope.actions'
              local action_state = require 'telescope.actions.state'

              -- Create entries that are compatible with telescope's built-in previewers
              local entries = {}
              for _, sym in ipairs(symbols) do
                if sym.location then
                  local filename = vim.uri_to_fname(sym.location.uri)
                  local rel_filename = vim.fn.fnamemodify(filename, ':.')
                  local lnum = sym.location.range.start.line + 1
                  local col = sym.location.range.start.character + 1
                  local display = string.format('%s:%d:%d - %s', rel_filename, lnum, col, sym.name)

                  table.insert(entries, {
                    filename = filename,
                    lnum = lnum,
                    col = col,
                    text = display,
                  })
                end
              end

              -- Create a horizontal layout with preview on the right
              local opts = {
                layout_strategy = 'horizontal',
                layout_config = {
                  preview_width = 0.5,
                },
                prompt_title = 'References to ' .. comp_name,
                finder = finders.new_table {
                  results = entries,
                  entry_maker = function(entry)
                    return {
                      value = entry,
                      display = entry.text,
                      ordinal = entry.text,
                      filename = entry.filename,
                      lnum = entry.lnum,
                      col = entry.col,
                    }
                  end,
                },
                previewer = conf.file_previewer {},
                sorter = conf.generic_sorter {},
                attach_mappings = function(prompt_bufnr)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.cmd('edit ' .. selection.filename)
                    vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
                  end)
                  return true
                end,
              }

              pickers.new(opts, {}):find()
            end)
          end, { noremap = true, silent = true, desc = '[V]ue find references to component' })
        end,
      }

      local vue_ls_config = {
        on_init = function(client)
          client.handlers['tsserver/request'] = function(_, result, context)
            local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'vtsls' }
            if #clients == 0 then
              vim.notify('Could not find `vtsls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
              return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
              title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
              command = 'typescript.tsserverRequest',
              arguments = {
                command,
                payload,
              },
            }, { bufnr = context.bufnr }, function(_, r)
              local response_data = { { id, r.body } }
              ---@diagnostic disable-next-line: param-type-mismatch
              client:notify('tsserver/response', response_data)
            end)
          end
        end,
      }

      vim.lsp.config('vtsls', vtsls_config)
      -- vim.lsp.config('vue_ls', vue_ls_config)
      -- vim.lsp.enable { 'vtsls', 'vue_ls' }
      vim.lsp.enable { 'vtsls' }

      local servers = {
        vue_ls = vtsls_config,
        -- vtsls = vtsls_config,

        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        --

        eslint = {},
        twiggy_language_server = {
          filetypes = { 'twig' },
        },

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        phpactor = {
          root_dir = function(pattern)
            -- find the first directory that contains a composer.json file and set the root dir for phpactor to that
            -- (because i usually open the whole project in neovim, not api or app directory)
            local util = require 'lspconfig.util'
            local cwd = vim.loop.cwd()
            local root = util.root_pattern 'composer.json'(pattern)

            -- prefer cwd if root is a descendant
            return util.path.is_descendant(root, cwd) and cwd or root
            -- return root
          end,
          init_options = {
            ['symfony.enabled'] = true,
            ['language_server_phpstan.enabled'] = true,
          },
          filetypes = { 'php' },
        },
        -- intelephense = {
        --   -- init_options = {
        --   --   licenceKey = '/Users/nnscr/intelephense/license.txt',
        --   -- },
        -- },
        prettierd = {},
        emmet_language_server = {
          -- filetypes = { 'html', 'vue' },
          init_options = {
            showSuggestionsAsSnippets = true,
          },
        },

        -- ts_ls = {
        --   -- NOTE: typescript and @vue/typescript-plugin both must be installed globally
        --   -- see from https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vue-support
        --   init_options = {
        --     hostInfo = 'neovim',
        --     plugins = {
        --       {
        --         name = '@vue/typescript-plugin',
        --         location = '/opt/homebrew/lib/node_modules/@vue/typescript-plugin/',
        --         languages = {
        --           'typescript',
        --           'typescriptreact',
        --           'javascript',
        --           'javascriptreact',
        --           'vue',
        --         },
        --       },
        --     },
        --     tsserver = {
        --       -- see https://github.com/k0mpreni/nvim-lua/blob/5948d7c8346f23863da68019929775b63321328c/after/plugin/lsp.lua#L17
        --       --path = require('mason-registry').get_package('typescript-language-server'):get_install_path() .. '/node_modules/typescript/lib',
        --       path = '/opt/homebrew/lib/node_modules/typescript/lib',
        --     },
        --   },
        --   on_attach = function()
        --     vim.keymap.set('n', '<leader>vg', function()
        --       -- Get component name from file name (e.g. MyComponent.vue -> "MyComponent")
        --       local comp_name = vim.fn.expand '%:t:r'
        --       local rg_cmd = 'rg --vimgrep "\\b' .. comp_name .. '\\b"'
        --       local results = vim.fn.systemlist(rg_cmd)
        --
        --       if vim.tbl_isempty(results) then
        --         vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
        --         return
        --       end
        --
        --       require('telescope.builtin').live_grep { default_text = comp_name }
        --     end, { desc = '[V]ue grep component name' })
        --     vim.keymap.set('n', '<leader>vv', function()
        --       -- Get the component name from the file's basename (e.g. MyComponent.vue → "MyComponent")
        --       local comp_name = vim.fn.expand '%:t:r'
        --
        --       vim.lsp.buf_request(0, 'workspace/symbol', { query = comp_name }, function(err, result)
        --         if err then
        --           vim.notify('Error: ' .. err.message, vim.log.levels.ERROR)
        --           return
        --         end
        --
        --         if not result or vim.tbl_isempty(result) then
        --           vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
        --           return
        --         end
        --
        --         -- Filter to include only symbols that have a valid location.
        --         local symbols = {}
        --         for _, sym in ipairs(result) do
        --           if sym.location then
        --             table.insert(symbols, sym)
        --           end
        --         end
        --
        --         if vim.tbl_isempty(symbols) then
        --           vim.notify('No references found for ' .. comp_name, vim.log.levels.INFO)
        --           return
        --         end
        --
        --         local pickers = require 'telescope.pickers'
        --         local finders = require 'telescope.finders'
        --         local conf = require('telescope.config').values
        --         local actions = require 'telescope.actions'
        --         local action_state = require 'telescope.actions.state'
        --
        --         -- Create entries that are compatible with telescope's built-in previewers
        --         local entries = {}
        --         for _, sym in ipairs(symbols) do
        --           if sym.location then
        --             local filename = vim.uri_to_fname(sym.location.uri)
        --             local rel_filename = vim.fn.fnamemodify(filename, ':.')
        --             local lnum = sym.location.range.start.line + 1
        --             local col = sym.location.range.start.character + 1
        --             local display = string.format('%s:%d:%d - %s', rel_filename, lnum, col, sym.name)
        --
        --             table.insert(entries, {
        --               filename = filename,
        --               lnum = lnum,
        --               col = col,
        --               text = display,
        --             })
        --           end
        --         end
        --
        --         -- Create a horizontal layout with preview on the right
        --         local opts = {
        --           layout_strategy = 'horizontal',
        --           layout_config = {
        --             preview_width = 0.5,
        --           },
        --           prompt_title = 'References to ' .. comp_name,
        --           finder = finders.new_table {
        --             results = entries,
        --             entry_maker = function(entry)
        --               return {
        --                 value = entry,
        --                 display = entry.text,
        --                 ordinal = entry.text,
        --                 filename = entry.filename,
        --                 lnum = entry.lnum,
        --                 col = entry.col,
        --               }
        --             end,
        --           },
        --           previewer = conf.file_previewer {},
        --           sorter = conf.generic_sorter {},
        --           attach_mappings = function(prompt_bufnr)
        --             actions.select_default:replace(function()
        --               actions.close(prompt_bufnr)
        --               local selection = action_state.get_selected_entry()
        --               vim.cmd('edit ' .. selection.filename)
        --               vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
        --             end)
        --             return true
        --           end,
        --         }
        --
        --         pickers.new(opts, {}):find()
        --       end)
        --     end, { noremap = true, silent = true, desc = '[V]ue find references to component' })
        --   end,
        --   filetypes = {
        --     'typescript',
        --     'typescriptreact',
        --     'javascript',
        --     'javascriptreact',
        --     'vue',
        --   },
        --   capabilities = capabilities,
        --
        --   -- only load ts_ls if there is a package.json in the root directory
        --   root_dir = require('lspconfig.util').root_pattern 'package.json',
        --   single_file_support = false,
        --
        --   commands = {
        --     OrganizeImports = {
        --       organize_imports,
        --       description = 'Organize Imports',
        --     },
        --   },
        -- },

        -- denols = {
        --   root_dir = require('lspconfig.util').root_pattern('deno.json', 'deno.jsonc'),
        -- },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_enable = true, -- Automatically enable servers that are installed
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}

            -- if server_name == 'vtsls' or server_name == 'vue_ls' then
            --   -- Skip vtsls and vue_ls, they are handled above
            --   return
            -- end

            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- require('lspconfig')[server_name].setup(server)
            vim.lsp.config(server_name, server)
          end,
        },
      }

      -- require('lspconfig').ts_ls.setup(servers.ts_ls)
      -- require('lspconfig').emmet_language_server.setup(servers.emmet_language_server)

      -- require('lspconfig').arduino_language_server.setup {
      --   filetypes = { 'arduino', 'cpp' },
      -- }
      -- require('lspconfig').ts_ls.setup { options from server map were here}
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 3000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        javascript = { 'prettierd' }, -- , 'prettier' } },
        typescript = { 'prettierd' }, -- , 'prettier' } },
        javascriptreact = { 'prettierd' }, -- , 'prettier' } },
        typescriptreact = { 'prettierd' }, -- , 'prettier' } },
        vue = { 'prettierd' },
        json = { 'prettierd' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        config = require('snips').config,
      },
      -- 'saadparwaiz1/cmp_luasnip',
      --
      -- -- Adds other completion capabilities.
      -- --  nvim-cmp does not ship with all sources by default. They are split
      -- --  into multiple repos for maintenance purposes.
      -- 'hrsh7th/cmp-nvim-lsp',
      -- 'hrsh7th/cmp-path',
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'enter',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          -- lsp = { module = 'blink.cmp.sources.lsp', score_offset = 100 },
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          -- snippets = { score_offset = -1000, enabled = true },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      -- fuzzy = { implementation = 'lua' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
    -- config = function()
    --   -- See `:help cmp`
    --   local cmp = require 'cmp'
    --   local luasnip = require 'luasnip'
    --   luasnip.config.setup {}
    --
    --   cmp.setup {
    --     snippet = {
    --       expand = function(args)
    --         luasnip.lsp_expand(args.body)
    --       end,
    --     },
    --     completion = { completeopt = 'menu,menuone,noinsert' },
    --
    --     -- add a nice little border and padding to the cmp windows
    --     window = {
    --       completion = cmp.config.window.bordered(),
    --       documentation = cmp.config.window.bordered(),
    --     },
    --
    --     -- For an understanding of why these mappings were
    --     -- chosen, you will need to read `:help ins-completion`
    --     --
    --     -- No, but seriously. Please read `:help ins-completion`, it is really good!
    --     mapping = cmp.mapping.preset.insert {
    --       -- Select the [n]ext item
    --       ['<C-n>'] = cmp.mapping.select_next_item(),
    --       -- Select the [p]revious item
    --       ['<C-p>'] = cmp.mapping.select_prev_item(),
    --
    --       -- Scroll the documentation window [b]ack / [f]orward
    --       ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    --       ['<C-f>'] = cmp.mapping.scroll_docs(4),
    --
    --       -- Accept ([y]es) the completion.
    --       --  This will auto-import if your LSP supports it.
    --       --  This will expand snippets if the LSP sent a snippet.
    --       ['<C-y>'] = cmp.mapping.confirm { select = true },
    --       -- ['<Tab>'] = cmp.mapping.confirm { select = true },
    --       ['<Enter>'] = cmp.mapping.confirm { select = true },
    --
    --       -- Manually trigger a completion from nvim-cmp.
    --       --  Generally you don't need this, because nvim-cmp will display
    --       --  completions whenever it has completion options available.
    --       ['<C-Space>'] = cmp.mapping.complete {},
    --
    --       -- Think of <c-l> as moving to the right of your snippet expansion.
    --       --  So if you have a snippet that's like:
    --       --  function $name($args)
    --       --    $body
    --       --  end
    --       --
    --       -- <c-l> will move you to the right of each of the expansion locations.
    --       -- <c-h> is similar, except moving you backwards.
    --       ['<C-l>'] = cmp.mapping(function()
    --         if luasnip.expand_or_locally_jumpable() then
    --           luasnip.expand_or_jump()
    --         end
    --       end, { 'i', 's' }),
    --       ['<C-h>'] = cmp.mapping(function()
    --         if luasnip.locally_jumpable(-1) then
    --           luasnip.jump(-1)
    --         end
    --       end, { 'i', 's' }),
    --
    --       -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --       --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    --     },
    --     sources = {
    --       {
    --         name = 'nvim_lsp',
    --         entry_filter = function(entry)
    --           -- Filter out `Text` completions, as they are not useful.
    --           return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
    --         end,
    --       },
    --       { name = 'luasnip' },
    --       { name = 'path' },
    --     },
    --   }
    -- end,
  },

  -- { -- You can easily change to a different colorscheme.
  --   -- Change the name of the colorscheme plugin below, and then
  --   -- change the command in the config to whatever the name of that colorscheme is.
  --   --
  --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   init = function()
  --     -- Load the colorscheme here. (default tokyonight-night)
  --     -- Like many other themes, this one has different styles, and you could load
  --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },
  {
    'rose-pine/neovim',
  },
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,
    config = function()
      require('github-theme').setup {
        groups = {
          all = {
            Cursor = {
              bg = '#FF0000',
              fg = '#000000',
            },
            lCursor = {
              bg = '#FF0000',
              fg = '#000000',
            },
            CursorIM = {
              bg = '#FF0000',
              fg = '#000000',
            },
            CursorInsert = {
              bg = '#FF00FF',
              fg = '#000000',
            },
          },
        },
      }

      -- vim.cmd.colorscheme 'github_light'
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    -- config = function()
    --   require('catppuccin').setup()
    --   vim.cmd.colorscheme 'catppuccin-latte'
    -- end,
  },

  {
    'tiagovla/tokyodark.nvim',
    opts = {
      transparent_background = true,
      styles = {
        comments = { italic = true }, -- style for comments
        keywords = { italic = false }, -- style for keywords
        identifiers = { italic = false }, -- style for identifiers
        functions = {}, -- style for functions
        variables = {}, -- style for variables
      },
      custom_palette = {
        bg2 = '#545567',
      },
    },
    config = function(_, opts)
      -- load setup with opts first, because some styles get overwritten here and the palette and
      -- highlights import would reset these back to the default values otherwise...
      require('tokyodark').setup(opts)
      -- local p = require 'tokyodark.palette'
      local h = require('tokyodark.highlights').highlights

      require('tokyodark').setup {
        custom_highlights = {
          ['@variable.member.vue'] = h.Function,
        },
      }
      vim.cmd.colorscheme 'tokyodark'
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      colors = {
        hint = { '#95C562' },
      },
    },
  },
  {
    'tpope/vim-surround',
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- auto close brackets, quotes, etc.
      -- require('mini.pairs').setup {}

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      --require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'vue', 'php', 'typescript', 'dockerfile', 'css', 'scss' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  { -- automatically save and restore sessions within ~/code and ~/.config directories
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      allowed_dirs = { '~/code/*', '~/code/*/*', '~/.config/*' },
      auto_restore = true,
      auto_save = true,
      log_level = 'error',
    },
  },
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = '[G]it [S]tatus' })
      vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = '[G]it [C]ommit' })
      -- vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = '[G]it [P]ush' })
      vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { desc = '[G]it [L]og' })
      vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = '[G]it [B]lame' })
      vim.keymap.set('n', '<leader>gr', ':Git branch<CR>', { desc = '[G]it B[r]anch' })
    end,
  },
  -- { -- auto close brackets, quotes, etc.
  --   'm4xshen/autoclose.nvim',
  --   config = function()
  --     require('autoclose').setup()
  --   end,
  -- },
  { -- copilot
    'zbirenbaum/copilot.lua',
    opts = {
      cmd = 'Copilot',
      event = 'InsertEnter',
    },
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          accept = false,
          auto_trigger = true,
        },
        filetypes = {
          yaml = true,
        },
      }

      -- accept suggestion with tab (https://github.com/zbirenbaum/copilot.lua/issues/91#issuecomment-1345190310)
      vim.keymap.set('i', '<Tab>', function()
        if require('copilot.suggestion').is_visible() then
          require('copilot.suggestion').accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
        end
      end, {
        silent = true,
      })

      -- vim.keymap.set('n', '<leader>gn', require('copilot.suggestion').next, { desc = 'Copilot: [N]ext suggestion' })
      vim.keymap.set('n', '<leader>gp', function()
        require('copilot.panel').open { position = 'right', ratio = 0.4 }
      end, { desc = 'Copilot: Open [P]anel' })
    end,
  },
  { -- Noice (floating windows for some stuff like :-Commands)
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
      routes = {
        {
          filter = { event = 'msg_show', kind = 'search_count' },
          opts = { skip = true },
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      {
        'rcarriga/nvim-notify',
        opts = {
          background_colour = '#1E1E1E',
          top_down = false,
        },
      },
    },
  },
  {
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ['<Esc>'] = 'actions.close',
        ['~'] = false,
        -- open telescope live grep with `*`
        ['*'] = {
          function()
            require('telescope.builtin').live_grep {
              cwd = require('oil').get_current_dir(),
              title = 'Live Grep in ' .. require('oil').get_current_dir(),
            }
          end,
          mode = 'n',
          nowait = true,
          desc = 'Find files in the current directory',
        },
      },
      view_options = {
        show_hidden = true,
      },
      git = {
        add = function()
          return true
        end,
        mv = function()
          return true
        end,
        rm = function()
          return true
        end,
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'chentoast/marks.nvim',
    opts = {},
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          -- lualine_c = { 'filename' },
          lualine_c = {
            'filename',
            -- {
            --   require('noice').api.status.message.get_hl,
            --   cond = require('noice').api.status.message.has,
            -- },
            -- {
            --   require('noice').api.status.command.get,
            --   cond = require('noice').api.status.command.has,
            --   color = { fg = '#ff9e64' },
            -- },
            -- {
            --   require('noice').api.status.mode.get,
            --   cond = require('noice').api.status.mode.has,
            --   color = { fg = '#ff9e64' },
            -- },
            {
              ---@diagnostic disable-next-line: undefined-field
              require('noice').api.status.search.get,
              ---@diagnostic disable-next-line: undefined-field
              cond = require('noice').api.status.search.has,
              color = { fg = '#95C562' },
            },
          },
          lualine_x = {
            function()
              local reg = vim.fn.reg_recording()
              if reg == '' then
                return ''
              end -- not recording
              return 'recording to ' .. reg
            end,
            'encoding',
            'fileformat',
            'filetype',
            'diagnostics',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup {
        user_default_options = {
          mode = 'virtualtext',
        },
      }
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    opts = {
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
        filetypes = { 'html', 'xml', 'vue' },
      },
    },
  },
  -- {
  --   -- taken from https://github.com/pmizio/typescript-tools.nvim/issues/249
  --   'pmizio/typescript-tools.nvim',
  --   dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  --   config = function()
  --     require('typescript-tools').setup {
  --       on_attach = function()
  --         -- auto organize imports when saving file
  --         -- vim.api.nvim_create_autocmd('BufWritePre', { command = ':TSToolsOrganizeImports' })
  --       end,
  --       filetypes = {
  --         'javascript',
  --         'javascriptreact',
  --         'typescript',
  --         'typescriptreact',
  --
  --         'vue', -- This needed to be added.
  --       },
  --       settings = {
  --         tsserver_plugins = {
  --           -- Seemingly this is enough, no name, location or languages needed.
  --           '@vue/typescript-plugin',
  --           -- {
  --           --   name = '@vue/typescript-plugin',
  --           --   location = '/opt/homebrew/lib/node_modules/@vue/typescript-plugin/',
  --           --   languages = {
  --           --     'typescript',
  --           --     'vue',
  --           --   },
  --           -- },
  --         },
  --       },
  --     }
  --   end,
  -- },
  {
    'tpope/vim-abolish',
  },
  {
    'olrtg/nvim-emmet',
    config = function()
      vim.keymap.set({ 'n', 'v' }, '<leader>cw', require('nvim-emmet').wrap_with_abbreviation, { desc = 'Emmet: [C]ode [W]rap' })
    end,
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon.setup {}

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<leader>A', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)
      vim.keymap.set('n', '<leader><leader>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, function()
          harpoon:list():select(i)
        end)
        vim.keymap.set('n', ',' .. i, function()
          harpoon:list():select(i)
        end, { desc = 'Harpoon: Navigate to ' .. i })
      end

      for i, key in ipairs { 'n', 'e', 'i', 'o' } do
        vim.keymap.set('n', ',' .. key, function()
          harpoon:list():select(i)
        end, { desc = 'Harpoon: Navigate to ' .. i })
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        enable = true,
        separator = '─',
        mode = 'topline',
      }
    end,
  },
  {
    'jaimecgomezz/here.term',
    config = function()
      local here_term = require 'here-term'
      here_term.setup {
        mappings = {
          enable = true,
        },
      }
      vim.keymap.set({ 'n', 't' }, '<leader>tt', function()
        here_term.toggle_terminal()
      end)
    end,
  },
  {
    'stevearc/overseer.nvim',
    config = function()
      local overseer = require 'overseer'

      overseer.setup {
        default_view = 'split',
        task_list = {
          min_height = 20,
        },
        -- default_width = 40,
        -- default_opts = {
        --   wrap = false,
        --   number = true,
        --   relativenumber = true,
        -- },
      }

      vim.keymap.set('n', '<leader>on', overseer.toggle, { desc = '[O]verseer Toggle (n)' })
      vim.keymap.set('n', '<leader>oo', function()
        overseer.run_template()
        overseer.open()
      end, { desc = '[O]verseer [A]ction' })
    end,
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    name = 'tailwind-tools',
    build = ':UpdateRemotePlugins',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim', -- optional
      'neovim/nvim-lspconfig', -- optional
    },
    opts = {}, -- your configuration
  },
  -- { -- Add indentation guides even on blank lines
  --   'lukas-reineke/indent-blankline.nvim',
  --   -- Enable `lukas-reineke/indent-blankline.nvim`
  --   -- See `:help ibl`
  --   main = 'ibl',
  --   opts = {},
  -- },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
