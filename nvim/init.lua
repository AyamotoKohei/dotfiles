-- Lazy.nvim
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

require("lazy").setup({
  -- iceberg
  {'cocopon/iceberg.vim', config=function() vim.cmd([[colorscheme iceberg]]) end,},
	-- Fern
  'nvim-tree/nvim-web-devicons',
	{
    'lambdalisue/fern.vim',
	  lazy = false, 
		priority = 1000,
		config = function()
      vim.g["fern#renderer"] = "nvim-web-devicons"
			vim.g["fern#default_hidden"]= 1
			vim.cmd([[
        augroup my-glyph-palette
        autocmd! *
        autocmd FileType fern call glyph_palette#apply()
        autocmd FileType nerdtree,startify call glyph_palette#apply()
        augroup END
      ]])
    end,
		},
	'lambdalisue/glyph-palette.vim',
	{'TheLeoP/fern-renderer-web-devicons.nvim',dependencies = {'nvim-web-devicons'}},
  --Syntax Highlight
  {'nvim-treesitter/nvim-treesitter'},
})

vim.opt.fileencoding = "utf-8"
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.title = true
vim.opt.signcolumn = 'yes' -- 行数表示の横に余白を追加
vim.opt.wrap = true        -- 端までコードが届いた際に折り返す
vim.opt.tabstop = 2
