-- general
-- lvim
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "onedarker"
lvim.builtin.notify.active = true
lvim.lsp.automatic_servers_installation = true
lvim.autocommands.custom_groups = {
      {"BufWritePre", "*", ":%s/\\s\\+$//e"},
}

--nvim
vim.opt.colorcolumn = "80"
vim.opt.spelllang = "en"
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.foldlevelstart=20
vim.opt.showbreak="<--"
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.foldenable = true
vim.opt.foldmethod= "indent"
vim.cmd("let g:vimspector_enable_mappings = 'HUMAN'")

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- add your own keymapping
lvim.keys.normal_mode["<S-l>"] = nil
lvim.keys.normal_mode["<S-h>"] = nil
lvim.keys.normal_mode["<C-Left>"] = nil
lvim.keys.normal_mode["<C-Right>"] = nil
lvim.keys.normal_mode["<F1>"] = ":NvimTreeToggle<cr>"
lvim.keys.normal_mode["<F2>"] = ":SymbolsOutline<cr>"
lvim.keys.normal_mode["<C-Left>"] = ":vertical resize +5<cr>"
lvim.keys.normal_mode["<C-Right>"] = ":vertical resize -5<cr>"
lvim.keys.normal_mode["<C-p>"] = ":Glow<cr>"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<A-Left>"] = ":BufferPrevious<cr>"
lvim.keys.normal_mode["<A-Right>"] = ":BufferNext<cr>"
lvim.keys.normal_mode["<A-w>"] = ":BufferClose<cr>"
lvim.keys.normal_mode["<A-1>"] = ":BufferGoto 1<cr>"
lvim.keys.normal_mode["<A-2>"] = ":BufferGoto 2<cr>"
lvim.keys.normal_mode["<A-3>"] = ":BufferGoto 3<cr>"
lvim.keys.normal_mode["<A-4>"] = ":BufferGoto 4<cr>"
lvim.keys.normal_mode["<A-5>"] = ":BufferGoto 5<cr>"
lvim.keys.normal_mode["<A-6>"] = ":BufferGoto 6<cr>"
lvim.keys.normal_mode["<A-7>"] = ":BufferGoto 7<cr>"
lvim.keys.normal_mode["<A-8>"] = ":BufferGoto 8<cr>"
lvim.keys.normal_mode["<A-9>"] = ":BufferGoto 9<cr>"
lvim.keys.normal_mode["<A-p>"] = ":BufferPick<cr>"
lvim.keys.normal_mode["<S-s>"] = ":lua require('spectre').open()<CR>"
lvim.keys.term_mode["<Esc>"] = "<C-\\><C-n><cr>"
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.open_on_setup = true
lvim.builtin.nvimtree.show_icons.git = 1
lvim.builtin.nvimtree.hide_dotfiles = 0
lvim.builtin.nvimtree.active = true
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.lualine.active = true
lvim.builtin.lualine.style = "default"
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.bufferline.active = true


-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "css",
  "rust",
  "java",
  "yaml",
}


-- Additional Plugins
lvim.plugins = {
    {
      "folke/trouble.nvim",
      cmd = "TroubleToggle",
    },
    { "sindrets/diffview.nvim" },
    {"lukas-reineke/indent-blankline.nvim",
        event = "BufRead",
        setup = function()
            vim.g.indentLine_enabled = 1
            vim.g.indent_blankline_char = "▏"
            vim.g.indent_blankline_filetype_exclude = {"help", "terminal", "dashboard"}
            vim.g.indent_blankline_buftype_exclude = {"terminal"}
            vim.g.indent_blankline_show_trailing_blankline_indent = false
            vim.g.indent_blankline_show_first_indent_level = false
        end
    },
    { "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        ft = "markdown",
        config = function()
          vim.g.mkdp_auto_start = 1
        end,
        },
    {
        "windwp/nvim-spectre",
        event = "BufRead",
        config = function()
            require("spectre").setup()
        end,
    },
    {
        "phaazon/hop.nvim",
        event = "BufRead",
        config = function()
            require("hop").setup()
            vim.api.nvim_set_keymap("n", "s", ":HopWord<cr>", { silent = true })
        end,
    },
    {
        "f-person/git-blame.nvim",
        event = "BufRead",
        config = function()
            vim.cmd "highlight default link gitblame SpecialComment"
            vim.g.gitblame_enabled = 0
        end,
    },
    {
        "nvim-treesitter/playground",
        event = "BufRead",
    },
--   {"github/copilot.vim"},
    {
        "metakirby5/codi.vim",
        cmd = "Codi",
    },
    {
        "tpope/vim-surround",
    },
    {
        "folke/todo-comments.nvim",
        event = "BufRead",
        config = function()
            require("todo-comments").setup()
        end,
    },
    {
      "andymass/vim-matchup",
      event = "CursorMoved",
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
      end,
    },
    {
      "nacro90/numb.nvim",
      event = "BufRead",
      config = function()
      require("numb").setup {
        show_numbers = true, -- Enable 'number' for the window while peeking
        show_cursorline = true, -- Enable 'cursorline' for the window while peeking
      }
      end,
    },
    {
      "kevinhwang91/nvim-bqf",
      event = { "BufRead", "BufNew" },
      config = function()
      require("bqf").setup({
                              auto_enable = true,
                              preview = {
                              win_height = 12,
                              win_vheight = 12,
                              delay_syntax = 80,
                              border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
                          },
      func_map = {
              vsplit = "",
              ptogglemode = "z,",
              stoggleup = "",
          },
          filter = {
              fzf = {
                  action_for = { ["ctrl-s"] = "split" },
                  extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
              },
          },
      })
      end,
    },
    {
      "simrat39/symbols-outline.nvim",
      cmd = "SymbolsOutline",
    },
    {"puremourning/vimspector"},
    {
      "npxbr/glow.nvim",
      ft = {"markdown"}
    },
     {
      "tpope/vim-fugitive",
      cmd = {
        "G",
        "Git",
        "Gdiffsplit",
        "Gread",
        "Gwrite",
        "Ggrep",
        "GMove",
        "GDelete",
        "GBrowse",
        "GRemove",
        "GRename",
        "Glgrep",
        "Gedit"
      },
      ft = {"fugitive"}
    },
    {'rbong/vim-flog'},
    {'samoshkin/vim-mergetool'},
    {'skywind3000/vim-quickui'},
    {'unblevable/quick-scope'},
    {'TamaMcGlinn/flog-menu'},
    {'TamaMcGlinn/flog-forest'},
    {"fabi1cazenave/termopen.vim"},
    {"sharksforarms/vimspector-gen"},
    {"vim-scripts/LargeFile"},
    {"simrat39/rust-tools.nvim",
        config = function()
          require("rust-tools").setup({
            tools = {
              autoSetHints = true,
              hover_with_actions = true,
              runnables = {
                use_telescope = true,
              },
            },
            server = {
              cmd = { vim.fn.stdpath "data" .. "/lsp_servers/rust/rust-analyzer" },
              on_attach = require("lvim.lsp").common_on_attach,
              on_init = require("lvim.lsp").common_on_init,
            },
            })
        end,
        ft = { "rust", "rs" },
    },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  {
    exe = "shellcheck", filetypes = {"sh"}
  },
  { exe = "flake8", filetypes = { "python" } },
  { exe = "eslint", filetypes = { "javascript", "typescript" } },

}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup
    {
        {exe = "prettier", filetypes = {"markdown", "javascript", "typescript" } },
        {exe = "rustfmt", filetypes = {"rust" } },
        { exe = "uncrustify",args = {} },
        { exe = "uncrustify", args = {} }

    }

