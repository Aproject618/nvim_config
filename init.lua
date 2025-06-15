-- Файл конфигурации: ~/.config/nvim/init.lua

-- Базовые настройки Neovim
vim.g.mapleader = " "
vim.opt.mouse = "a"  -- Полная поддержка мыши
vim.opt.scroll = 5  -- Плавная прокрутка
vim.opt.mousemodel = "extend"  -- Двойной клик выделяет слово
vim.opt.termguicolors = true  -- True-color поддержка
vim.opt.cursorline = true  -- Подсветка текущей строки

-- Инициализация lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Базовые цветовые настройки
vim.api.nvim_set_hl(0, "Normal", { fg = "#c56df7", bg = "#1a1b26" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#565f89", italic = true })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#717c7c" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#363646" })
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#ff9e64", bold = true })

-- Настройка плагинов
require("lazy").setup({
  -- Treesitter (вместо vim-polyglot)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "go", "sql" },  -- Убедитесь, что Go и Python установлены
        highlight = { enable = true },
      })
    end,
  },

  -- Mason для установки LSP серверов
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Интеграция Mason с nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "gopls" },  -- Установим Python и Go LSP серверы
      })
    end,
  },

  -- LSP конфигурация
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Настройка LSP для Python
      require("lspconfig").pyright.setup({})

      -- Настройка LSP для Go
      require("lspconfig").gopls.setup({
        cmd = { "gopls" },  -- Убедитесь, что gopls установлен
        filetypes = { "go", "gomod" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      })
    end,
  },

  -- Автодополнение
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-Space>"] = cmp.mapping.complete(),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "vim-dadbod-completion" },
        }
      })
    end,
  },

  -- Работа с БД
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-ui" },

  -- Форматирование SQL
  { "mattn/vim-sqlfmt" },
})

-- Кастомные цвета SQL (выполняется после загрузки плагинов)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- SQL-специфичные цвета
    vim.api.nvim_set_hl(0, "sqlKeyword", { fg = "#b43ffc", bold = true })
    vim.api.nvim_set_hl(0, "sqlFunction", { fg = "#bb9af7", italic = true })
    vim.api.nvim_set_hl(0, "sqlType", { fg = "#ff9e64" })
    vim.api.nvim_set_hl(0, "sqlTable", { fg = "#f7768e" })
    vim.api.nvim_set_hl(0, "sqlString", { fg = "#9ece6a" })
    
    -- Цвета DBUI
    vim.api.nvim_set_hl(0, "DBUIHeader", { fg = "#7aa2f7" })
    vim.api.nvim_set_hl(0, "DBUITableName", { fg = "#bb9af7" })
    vim.api.nvim_set_hl(0, "DBUIField", { fg = "#9ece6a" })
  end
})

-- Горячие клавиши
vim.api.nvim_set_keymap("n", "<leader>r", ":DB<CR>", { noremap = true, silent = true })

-- Дополнительные настройки SQL
vim.g.sqlfmt_command = "sqlfmt"
vim.g.sqlfmt_options = "-u"

-- Функция для подсветки слов, состоящих только из заглавных букв
vim.api.nvim_exec([[
  function! HighlightCapsWords()
    " Подсвечиваем только слова, состоящие из заглавных букв
    match Keyword /\v\<\u+\>/  " Ищем слова, состоящие из заглавных букв
  endfunction

  " Вызываем функцию для подсветки после загрузки буфера
  autocmd BufWinEnter * call HighlightCapsWords()
]], false)

-- Настройка цветов для подсветки
vim.cmd [[
  highlight Keyword guifg=#5cfae2  " Изменяем цвет шрифта для слов CapsLock
]]
