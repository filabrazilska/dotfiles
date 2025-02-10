-- initialize lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.wo.number = true

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
  {
  "overcache/NeoSolarized",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd [[ colorscheme NeoSolarized ]]
    end
  },
  "nvim-lualine/lualine.nvim", -- status line
  -- LSP progress bar
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach",
    opts = {
      -- options
    },
  },

  -- package manager (to install MS cpptools from vscode)
  "williamboman/mason.nvim",

  -- symbols viewer
  "liuchengxu/vista.vim",
  {
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    },
    lazy = false,
  },

  -- filesystem viewer
  { "nvim-tree/nvim-tree.lua" },

  {
    'mrcjkb/rustaceanvim',
    version = '^3', -- Recommended
    ft = { 'rust' },
  },

  { "folke/neodev.nvim", opts = {} }, -- nvim config development

  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp", -- autocompletion
  "hrsh7th/cmp-nvim-lsp", -- cmp LSP completion
  "hrsh7th/vim-vsnip", -- Snippet engine
  "hrsh7th/cmp-vsnip", -- cmp Snippet completion
  "hrsh7th/cmp-path", -- cmp Path completion
  "hrsh7th/cmp-buffer",
  "nvim-telescope/telescope.nvim",
  "nvim-lua/popup.nvim",
  "phaazon/hop.nvim",

  "nvim-treesitter/nvim-treesitter",

  -- git
  "tpope/vim-fugitive",

  -- debugger
  "nvim-lua/plenary.nvim",
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "theHamsta/nvim-dap-virtual-text",
  "nvim-neotest/nvim-nio",

  -- rr debugger
  {"jonboh/nvim-dap-rr", dependencies = {"nvim-dap", "telescope.nvim"}},

  -- using LLMs
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "codellama:13b-python", -- The default model to use.
      display_mode = "float", -- The display mode. Can be "float" or "split".
      show_prompt = false, -- Shows the Prompt submitted to Ollama.
      show_model = true, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
      -- Function to initialize Ollama
      command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a lua function returning a command string, with options as the input parameter.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      list_models = '<omitted lua function>', -- Retrieves a list of model names
      debug = false -- Prints errors and the command which is run.
    }
  },

  -- golang
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },

  -- python
  {
    "davidhalter/jedi-vim",
  },

  -- markdown rendering
  {
    "https://github.com/OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
  },

  -- zig
  {
    "ziglang/zig.vim",
  },
})

vim.opt.termguicolors = true

require("mason").setup()

require('Comment').setup({
  toggler = {
    line = '<f3>',
  },
  opleader = {
    block = '<f3>',
  },
})

require("lualine").setup{ options = { theme = "solarized_light" }, }

-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
vim.o.completeopt = "menuone,noinsert,noselect"

-- Avoid showing extra messages when using completion
vim.opt.shortmess = vim.opt.shortmess + "c"

-- Set updatetime for CursorHold
-- 300ms of no cursor movement to trigger CursorHold
vim.opt.updatetime = 100

-- Open the hover menu at the place of a right click
vim.keymap.set("n", "<RightMouse>", "<LeftMouse><Cmd>lua vim.lsp.buf.hover()<CR>")

-- Mappings.
local keymaps = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<s-left>', '<cmd>tabp<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<s-right>', '<cmd>tabn<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<s-left>', '<esc><cmd>tabp<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<s-right>', '<esc><cmd>tabn<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', keymaps)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', keymaps)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', keymaps)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', keymaps)
vim.api.nvim_set_keymap('n', '<f2>', '<cmd>Vista!!<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<f2>', '<esc><cmd>Vista!!<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<f4>', '<cmd>set invnumber<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<f4>', '<esc><cmd>set invnumber<cr>i', keymaps)
vim.api.nvim_set_keymap('n', '<c-p>', '<cmd>Telescope find_files<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<c-p>', '<esc><cmd>Telescope find_files<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<c-q>', '<cmd>Telescope grep_string<cr>', keymaps)
vim.api.nvim_set_keymap('i', '<c-q>', '<esc><cmd>Telescope live_grep<cr>', keymaps)

-- Setting up Hop to jump around
require("hop").setup()
vim.api.nvim_set_keymap('n', '<Leader>f', '<cmd>HopChar1<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<Leader>w', '<cmd>HopWord<cr>', keymaps)
vim.api.nvim_set_keymap('n', '<Leader>/', '<cmd>HopPattern<cr>', keymaps)
vim.api.nvim_set_hl(0, "HopNextKey", {cterm=bold, ctermfg=1})
vim.api.nvim_set_hl(0, "HopNextKey1", {cterm=bold, ctermfg=5})
vim.api.nvim_set_hl(0, "HopNextKey2", {cterm=bold, ctermfg=8})

-- on_attach handler triggered when LSP is ready for a buffer
local on_attach = function(client, bufnr)
  -- make hints more visible
  vim.cmd [[ hi DiagnosticHint guifg=Grey ]]
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', keymaps)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({timeout_ms=5000, async=true})<CR>', keymaps)
end

vim.g.rustaceanvim = {
  server = {
    on_attach = on_attach,
    settings = {
      -- to enable rust-analyzer settings visit:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
}

-- Make sure dapui is open when debugging starts
local dap, dapui = require("dap"), require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- vim.api.nvim_set_keymap('n', '<s-left>', '<cmd>tabp<cr>', keymaps)
vim.keymap.set("n", "<F1>", dap.terminate)
vim.keymap.set("n", "<F14>", dap.run_to_cursor) -- <S-F2> == <F14>
vim.keymap.set("n", "<F6>", dap.continue)
vim.keymap.set("n", "<F8>", dap.pause)
vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
-- <S-F9> == <F21>
vim.keymap.set("n", "<F21>", function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F23>", dap.step_out) -- <S-F11> == <F23>
vim.keymap.set("n", "<F56>", dap.down) -- <A-F8>
vim.keymap.set("n", "<F57>", dap.up) -- <A-F9>

-- Visual evaluation 
vim.keymap.set("v", "<F5>", "<Cmd>lua require(\"dapui\").eval()<CR>")
vim.keymap.set("n", "<F5>", "<Cmd>lua require(\"dapui\").eval("..vim.fn.expand('<cword>')..")<CR>")


vim.keymap.set("n", "<F12>", function()
    dapui.toggle(1)
    dapui.toggle(2)
end)

require('nvim-dap-virtual-text').setup()

-- Setup rr debugger
-- point dap to the installed cpptools
-- local cpptools_path = vim.fn.stdpath("data").."/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7"
-- dap.adapters.cppdbg = {
--     id = 'cppdbg',
--     type = 'executable',
--     command = cpptools_path,
-- }
-- 
-- local rr_dap = require("nvim-dap-rr")
-- rr_dap.setup({
--     mappings = {
--         -- you will probably want to change these defaults to that they match
--         -- your usual debugger mappings
--         continue = "<F7>",
--         step_over = "<F8>",
--         step_out = "<F9>",
--         step_into = "<F10>",
--         reverse_continue = "<F19>", -- <S-F7>
--         reverse_step_over = "<F20>", -- <S-F8>
--         reverse_step_out = "<F21>", -- <S-F9>
--         reverse_step_into = "<F22>", -- <S-F10>
--         -- instruction level stepping
--         step_over_i = "<F32>", -- <C-F8>
--         step_out_i = "<F33>", -- <C-F8>
--         step_into_i = "<F34>", -- <C-F8>
--         reverse_step_over_i = "<F44>", -- <SC-F8>
--         reverse_step_out_i = "<F45>", -- <SC-F9>
--         reverse_step_into_i = "<F46>", -- <SC-F10>
--     }
-- })
-- dap.configurations.rust = { rr_dap.get_rust_config() }
-- dap.configurations.cpp = { rr_dap.get_config() }
-- --table.insert(dap.configurations.rust, rr_dap.get_rust_config())
-- --table.insert(dap.configurations.cpp, rr_dap.get_config())

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require("cmp")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    -- Add tab support
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  },

  -- Installed sources
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

local lspconfig = require('lspconfig')
lspconfig.ccls.setup {
  init_options = {
    cache = {
      directory = ".ccls-cache";
    };
  }
}

-- Golang plugin setup
require('go').setup()
lspconfig.gopls.setup {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

-- Python plugin setup (https://github.com/pappasam/jedi-language-server)
lspconfig.jedi_language_server.setup{}
lspconfig.ruff.setup{}
-- lspconfig.pyright.setup{}
--local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
--vim.api.nvim_create_autocmd("BufWritePre", {
--  pattern = "*.go",
--  callback = function()
--   require('go.format').goimports()
--  end,
--  group = format_sync_grp,
--})

-- empty setup using defaults
require("nvim-tree").setup()

-- Zig specific LSP setup
lspconfig.zls.setup {
  cmd = { '/home/fila/bin/zls' },
}
