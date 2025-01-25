-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny



table.insert(lvim.plugins, {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" },                       -- or zbirenbaum/copilot.lua
    { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
  },
  build = "make tiktoken",                          -- Only on MacOS or Linux
  opts = {
    -- See Configuration section for options
  },
  -- See Commands section for default commands if you want to lazy load on them
})

-- Blade syntax highlighting
table.insert(lvim.plugins, { "jwalton512/vim-blade" })
vim.cmd [[
  autocmd FileType blade setlocal foldmethod=indent
]]

-- Keybindings for Copilot Chat
lvim.keys.normal_mode["<leader>cc"] = ":CopilotChatOpen<CR>"  -- Open the Copilot Chat panel
lvim.keys.normal_mode["<leader>cq"] = ":CopilotChat quit<CR>" -- Close the Copilot Chat panel

-- Prevent Copilot from overriding <Tab>
vim.g.copilot_no_tab_map = true



-- Optional: Map ctrl+ enter to accept Copilot suggestions
-- map ctrl + right arrow to accept copilot suggestions
vim.api.nvim_set_keymap("i", "<C-Right>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-]>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=20 direction=horizontal<cr>", "Split horizontal" },
}


-- configure eslint for vue
table.insert(lvim.plugins, { "jose-elias-alvarez/null-ls.nvim" })
require('lspconfig')


local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Existing source for ESLint
    null_ls.builtins.diagnostics.eslint.with({
      filetypes = { "javascript", "javascriptreact", "vue" }
    }),
    null_ls.builtins.formatting.eslint_d.with({
      filetypes = { "javascript", "javascriptreact", "vue" }
    }),
    -- null_ls.builtins.formatting.blade_formatter,
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "blade", 'javascript' },
      extra_args = { "--ignore-unknown" },
    }),
    null_ls.builtins.formatting.pint.with({
      command = "pint", -- Use globally installed Pint
      args = { "$FILENAME" },
      method = null_ls.methods.FORMATTING,
      filetypes = { "php" },
    }),
  },
  timeout = 10000,
  on_attach = function(client, bufnr)
    -- Enable diagnostics from LSP
    if client and client.resolved_capabilities and client.resolved_capabilities.diagnostics then
      vim.cmd [[autocmd CursorHold <buffer> lua vim.diagnostic.open_float()]]
    end
  end,
})

-- Path to global installations
local vue_language_server_path = "/home/ysghayron/.nvm/versions/node/v21.6.2/lib/node_modules/@vue/language-server"
local typescript_sdk_path = "/home/ysghayron/.nvm/versions/node/v21.6.2/lib/node_modules/typescript/lib"

-- Volar setup for .vue files
require('lspconfig').volar.setup {
  filetypes = { 'vue' },
  root_dir = require('lspconfig.util').root_pattern('package.json', 'vue.config.js', '.git'),
  init_options = {
    vue = {
      hybridMode = true,               -- Enable Hybrid Mode
      useWorkspaceDependencies = true, -- Enable Workspace Dependencies
    },
    typescript = {
      tsdk = typescript_sdk_path, -- Path to TypeScript SDK
    },
  },
}

-- tsserver setup for JS/TS and Vue support
require('lspconfig').tsserver.setup {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path, -- Path to Vue plugin
        languages = { "vue" },
      },
    },
    tsdk = typescript_sdk_path, -- Path to TypeScript SDK
  },
  on_attach = function(client, bufnr)
    local function goto_source_definition()
      local position_params = vim.lsp.util.make_position_params()
      vim.lsp.buf.execute_command({
        command = "_typescript.goToSourceDefinition",
        arguments = { vim.api.nvim_buf_get_name(0), position_params.position },
      })
    end

    vim.keymap.set('n', 'gs', goto_source_definition, { buffer = bufnr })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  end,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  root_dir = require('lspconfig.util').root_pattern('tsconfig.json', 'jsconfig.json', '.git'),
  handlers = {
    ["workspace/executeCommand"] = function(_err, result, ctx, _config)
      if ctx.params.command ~= "_typescript.goToSourceDefinition" then
        return
      end
      if result == nil or #result == 0 then
        return
      end
      vim.lsp.util.jump_to_location(result[1], "utf-8")
    end,
  },
}

vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })]]

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
  cmd = { "/usr/local/bin/phpactor", "language-server" },
  filetypes = { "php" },
  root_dir = function(fname)
    return lspconfig.util.root_pattern("composer.json", ".git")(fname) or vim.fn.getcwd()
  end,
  on_attach = function(client, bufnr)
    -- Disable referencesProvider for PHPActor
    client.server_capabilities.referencesProvider = false
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


table.insert(lvim.plugins, { "posva/vim-vue" })

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
-- select all
lvim.keys.normal_mode['<leader>va'] = 'ggVG'
-- Split mappings
lvim.keys.normal_mode['<leader>svs'] = ':Vsplit<CR>'
lvim.keys.normal_mode['<leader>shs'] = ':Hsplit<CR>'

-- Git Messenger
lvim.keys.normal_mode["<leader>gm"] = ":GitMessenger<CR>"

-- Symbols Outline
lvim.keys.normal_mode["<leader>lo"] = ":SymbolsOutline<CR>"


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

-- Append new mappings for Select
which_key["v"] = which_key["v"] or { name = "+Select" }
which_key["v"].a = { "ggVG", "Select all" }

-- Append new mappings for Splits
which_key["s"] = which_key["s"] or { name = "+Splits" }
which_key["s"].vs = { "<cmd>Vsplit<CR>", "Vertical split" }
which_key["s"].hs = { "<cmd>Hsplit<CR>", "Horizontal split" }

-- Append new mappings for Git
which_key["g"] = which_key["g"] or { name = "+Git" }
which_key["g"].m = { "<cmd>GitMessenger<CR>", "Git Messenger" }

-- Append new mappings for Outline
which_key["l"] = which_key["l"] or { name = "+Outline" }
which_key["l"].o = { "<cmd>SymbolsOutline<CR>", "Symbols Outline" }


table.insert(lvim.plugins, {
  "yahyasghayron/nvim-laravel",
  opts = {
    keybindings = {
      open_config_value = "<leader>gx",
    },
  },
})

-- git signs
table.insert(lvim.plugins, {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup(
      {
        current_line_blame = true, -- Toggle to always show inline blame
        sign_priority = 6,
        update_debounce = 100,
        max_file_length = 40000,
      }
    )
  end,
})


table.insert(lvim.plugins, {"isak102/telescope-git-file-history.nvim",
  dependencies= { "nvim-lua/plenary.nvim", "tpope/vim-fugitive" },
  config = function()
    require("telescope").load_extension("git_file_history")
  end,
})

require("telescope").load_extension("git_file_history")

vim.keymap.set('n', '<leader>gh', function()
  require('telescope').extensions.git_file_history.git_file_history()
end, { desc = "Show Git history for the current file" })

vim.keymap.set('v', '<leader>gl', function()
    -- Get the selected range
    local file = vim.fn.expand('%') -- Current file path
    local start_line = vim.fn.getpos("'<")[2] -- Start line of the selection
    local end_line = vim.fn.getpos("'>")[2]   -- End line of the selection

    -- Build the git log -L command
    local command = string.format("git log -L%d,%d:%s --date=format:'%%Y-%%m-%%d' --pretty=format:'%%H | %%ad | %%s'", start_line, end_line, file)

    -- Run the command and capture output
    local output = vim.fn.systemlist(command)

    -- Check for errors or empty results
    if vim.v.shell_error ~= 0 or #output == 0 then
        vim.notify("No Git history found for the selected range.", vim.log.levels.INFO)
        return
    end

    -- Parse the output into a structured table
    local entries = {}
    for _, line in ipairs(output) do
        local commit, date, message = line:match("^(%S+) | (%S+) | (.+)$")
        if commit and date and message then
            table.insert(entries, { commit = commit, date = date, message = message })
        end
    end

    -- Custom previewer to display the diff for a selected commit
    local previewer = require('telescope.previewers').new_termopen_previewer({
        get_command = function(entry)
            return { "git", "show", entry.value.commit }
        end,
    })

    -- Use Telescope to display the results
    require('telescope.pickers').new({}, {
        prompt_title = "Git History (Selection)",
        finder = require('telescope.finders').new_table({
            results = entries,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format("%s | %s | %s", entry.commit:sub(1, 8), entry.date, entry.message),
                    ordinal = entry.commit .. " " .. entry.date .. " " .. entry.message,
                }
            end,
        }),
        sorter = require('telescope.config').values.generic_sorter({}),
        previewer = previewer,
    }):find()
end, { desc = "Show Git history for the selected range" })

