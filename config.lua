-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


table.insert(lvim.plugins, {
  "zbirenbaum/copilot-cmp",
  event = "InsertEnter",
  dependencies = { "zbirenbaum/copilot.lua" },
  config = function()
    vim.defer_fn(function()
      require("copilot").setup()     -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
      require("copilot_cmp").setup() -- https://github.com/zbirenbaum/copilot-cmp/blob/master/README.md#configuration
    end, 100)
  end,
})

lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=20 direction=horizontal<cr>", "Split horizontal" },
}


table.insert(lvim.plugins, { "posva/vim-vue" })

-- Treesitter configuration
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "vue", "javascript", "html", "css" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}


-- configure eslint for vue
table.insert(lvim.plugins, { "jose-elias-alvarez/null-ls.nvim" })
require('lspconfig')
local null_ls = require("null-ls")


null_ls.setup({
  sources = {
    -- Existing source for ESLint
    null_ls.builtins.formatting.eslint_d.with({
      filetypes = { "javascript", "javascriptreact", "vue" }
    }),
    -- New source for PHP-CS-Fixer
    null_ls.builtins.formatting.phpcsfixer.with({
      args = {"fix", "--config=.php-cs-fixer.dist.php", "$FILENAME"},
      method = null_ls.methods.FORMATTING,
      filetypes = { "php" },
    }),
  },
  on_attach = function(client, bufnr)
    -- Enable diagnostics from LSP
    if client and client.resolved_capabilities and client.resolved_capabilities.diagnostics then
      vim.cmd [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float()]]
    end
  end,
})

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "volar" })
require "lspconfig".volar.setup {
  filetypes = { "vue", "javascript" },
  init_options = {
    typescript = {
      tsdk = '/home/ysghayron/.nvm/versions/node/v21.6.2/lib/node_modules/typescript/lib/'
    }
  },
  settings = {
    volar = {
      useWorkspaceTsdk = false,             -- Disable workspace TypeScript search
      vueVersion = 2,                       -- Vue 2 specific settings
      experimental = {
        templateInterpolationService = true -- Enable template intellisense for Vue 2
      }
    }
  },
}

table.insert(lvim.plugins, { "catgoose/vue-goto-definition.nvim" })
require 'vue-goto-definition'.setup({
  keymaps = {
    goto_definition = 'gd', -- Keymap for going to the definition
    peek_definition = 'gD'  -- Keymap for peeking at the definition
  },
})




-- Import the 'dap' module
local dap = require("dap")

-- Configure the debugger adapter for PHP
dap.adapters.php = {
  type = "executable",
  command = "node",
  args = {
    "/home/ysghayron/.local/share/lvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
  },
}

-- Debug configurations specific to PHP
dap.configurations.php = {
  {
    type = "php",
    request = "launch",
    name = "Local Development",
    port = 9003,
    pathMappings = {
      ["/var/www/server"] = "${workspaceFolder}",
    },
  },
  {
    type = "php",
    request = "launch",
    name = "Docker Development",
    port = 9003,
    hostname = "0.0.0.0",
    pathMappings = {
      ["/var/www/server/"] = "${workspaceFolder}",
    },
  },
}


-- table.insert(lvim.lsp.automatic_configuration.skipped_servers, 'intelephense')
-- LSP configuration for PHPactor
local lspconfig = require('lspconfig')

lspconfig.phpactor.setup {
  cmd = { "/usr/local/bin/phpactor", "language-server" }, -- Path to your local PHPactor installation
  filetypes = { "php" },
  root_dir = function(fname)
    return lspconfig.util.root_pattern("composer.json", ".git")(fname) or vim.fn.getcwd()
  end,
}



-- lvim.builtin.nvimtree.setup.view.side = "right"




-- folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99
vim.opt.foldenable = true

-- folding for python
if vim.bo.filetype == 'python' then
  vim.opt.foldmethod = 'indent'
end




-- sticky context
table.insert(lvim.plugins, { "nvim-treesitter/nvim-treesitter-context" })

require "treesitter-context".setup {
  enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
  throttle = true, -- Throttles plugin updates (may improve performance)
  max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit
}


-- git history
table.insert(lvim.plugins, { "rhysd/git-messenger.vim" })
-- map to <leader>gm to show git messages


-- symbols-outline.nvim
table.insert(lvim.plugins, {
  "simrat39/symbols-outline.nvim",
  config = function()
    require("symbols-outline").setup({
      highlight_hovered_item = true,
      show_guides = true,
    })
  end,
})


-- todo comments
table.insert(lvim.plugins, {
  "folke/todo-comments.nvim",
  event = "BufRead",
  config = function()
    require("todo-comments").setup()
  end,
})


-- telescope
lvim.builtin.telescope.defaults.file_ignore_patterns = { "vendor/", "swagger/", "node_modules/", "%.lock" }


require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "vue", "javascript", "typescript", "html", "css" }, -- Add 'vue' here
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}




-- set file type to json and  quick json formatting 
lvim.keys.normal_mode["<leader>jq"] = ":set ft=json<CR>:%!jq '.'<CR>"
-- create new buffer
lvim.keys.normal_mode["<leader>bc"] = ":enew<CR>"
-- force close buffer without saving
lvim.keys.normal_mode['<leader>bx'] = ':bd!<CR>'
-- copy whole file content
lvim.keys.normal_mode['<leader>ya'] = ':%y+<CR>'
-- Split mappings
lvim.keys.normal_mode['<leader>svs'] = ':Vsplit<CR>'
lvim.keys.normal_mode['<leader>shs'] = ':Hsplit<CR>'

-- Git Messenger
lvim.keys.normal_mode["<leader>gm"] = ":GitMessenger<CR>"

-- Symbols Outline
lvim.keys.normal_mode["<leader>so"] = ":SymbolsOutline<CR>"

-- Which Key Configuration
local which_key = lvim.builtin.which_key.mappings

-- Append new mappings for Quick actions
which_key["j"] = which_key["j"] or { name = "+Quick actions" }
which_key["j"].j = { "<cmd>set ft=json<CR>:%!jq '.'<CR>", "Quick format JSON" }

-- Append new mappings for Buffers
which_key["b"] = which_key["b"] or { name = "+Buffers" }
which_key["b"].c = { "<cmd>enew<CR>", "Create new buffer" }
which_key["b"].x = { "<cmd>bd!<CR>", "Force close buffer" }

-- Append new mappings for Copy
which_key["y"] = which_key["y"] or { name = "+Copy" }
which_key["y"].a = { ":%y+<CR>", "Copy whole file content" }

-- Append new mappings for Splits
which_key["s"] = which_key["s"] or { name = "+Splits" }
which_key["s"].vs = { "<cmd>Vsplit<CR>", "Vertical split" }
which_key["s"].hs = { "<cmd>Hsplit<CR>", "Horizontal split" }

-- Append new mappings for Git
which_key["g"] = which_key["g"] or { name = "+Git" }
which_key["g"].m = { "<cmd>GitMessenger<CR>", "Git Messenger" }

-- Append new mappings for Outline
which_key["o"] = which_key["o"] or { name = "+Outline" }
which_key["o"].so = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" }

