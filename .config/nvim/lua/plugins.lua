-- TODO:
-- 		https://github.com/folke/trouble.nvim
-- 		https://github.com/puremourning/vimspector if possible
-- 		treesitter treeobjects + movements that come with it
--
-- 		example at: https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

return require('packer').startup(function(use)
	-- package manager
	use 'wbthomason/packer.nvim'

	-- themes
	use 'sainnhe/gruvbox-material'

	-- better highlighting
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

	-- brackets manipulation
	use 'tpope/vim-surround'
	use {
		'windwp/nvim-autopairs',
		config = function() require('nvim-autopairs').setup({
				disable_in_macro = true,
			})
		end
	}
	-- use 'luochen1990/rainbow'

	-- css colors
	use 'ap/vim-css-color'

	-- show indentlines
	use {
		'lukas-reineke/indent-blankline.nvim',
		config = function() require('indent_blankline').setup({
				show_first_indent_level = false,
			})
		end
	}

	-- easily change stuff
	use 'tpope/vim-abolish'
	use 'mbbill/undotree'
	use 'mg979/vim-visual-multi'
	use {
		'numToStr/Comment.nvim',
		config = function() require('Comment').setup() end
	}

	-- icons, used by other plugins
	use 'nvim-tree/nvim-web-devicons'

	-- Telescope
	use {
		'nvim-telescope/telescope.nvim',
		tag = '0.1.0',
		requires = { { 'nvim-lua/plenary.nvim' } },
		config = function() require('configs.telescope') end
	}
	use {
		'nvim-telescope/telescope-fzf-native.nvim',
		run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
	}

	-- Trouble
	use {
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("configs.trouble")
		end
	}

	-- code naviation
	use {
		'romgrk/barbar.nvim',
		requires = { { 'nvim-tree/nvim-web-devicons' } },
		config = function() require('configs.barbar') end,
	}

	-- LSP
	use 'neovim/nvim-lspconfig'

	-- rust
	use {
		'simrat39/rust-tools.nvim',
		requires = { { 'nvim-lua/plenary.nvim' } },
	}

	-- typescript
	use 'jose-elias-alvarez/typescript.nvim'

	-- completions
	use {
		'hrsh7th/nvim-cmp',
		config = function() require('configs.comps') end
	}

	-- completion sources
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-nvim-lua'

	-- snippets
	use 'L3MON4D3/LuaSnip'
	use 'saadparwaiz1/cmp_luasnip'

	-- git
	use {
		'lewis6991/gitsigns.nvim',
		tag = 'release' -- To use the latest release (do not use this if you run Neovim nightly or dev builds!)
	}

	-- use 'itchyny/lightline.vim'
	-- use 'mengelbrecht/lightline-bufferline'
	--
	-- -- " file browsing
	-- -- use 'lambdalisue/fern.vim'
	-- -- use 'lambdalisue/fern-renderer-nerdfont.vim'
	-- -- use 'lambdalisue/fern-git-status.vim'
	-- -- use 'lambdalisue/nerdfont.vim'
	-- -- " this needed for some problem
	-- -- use 'antoinemadec/FixCursorHold.nvim'
	--
	-- use 'neoclide/coc.nvim', {'branch': 'release'}
	-- use 'lervag/vimtex', { 'for': 'tex' }
	-- -- use 'gabrielelana/vim-markdown', { 'for': 'markdown' }
	-- use 'tikhomirov/vim-glsl', { 'for': 'glsl' }
	-- use 'mattn/emmet-vim', { 'for': 'html' }
	-- use 'cespare/vim-toml', { 'for' : 'toml' }
	-- use 'abhikjain360/wgsl.vim', { 'for': 'wgsl' }
	-- use 'ziglang/zig.vim', { 'for': 'zig' }
	-- use 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	-- use 'p00f/nvim-ts-rainbow'

end)
