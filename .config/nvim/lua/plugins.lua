-- TODO:
--       - file manager

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
	use {
		'mbbill/undotree',
		config = function()
			vim.keymap.set('n', '<space>u', '<cmd>UndotreeToggle<cr>', { noremap = true, silent = true })
			vim.cmd('let g:undotree_SplitWitdh = 40')
		end
	}
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
		requires = "nvim-tree/nvim-web-devicons",
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
	use {
		'nvim-treesitter/nvim-treesitter-textobjects',
		config = function() require('configs.treeobjects') end
	}
	use {
		'nvim-treesitter/nvim-treesitter-context',
		config = function() require 'treesitter-context'.setup { enable = true } end
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

	use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons', -- optional, for file icons
		},
		config = function() require('configs.nvim_tree') end
	}

	-- specific syntax highlighting not by default in vim
	use { 'tikhomirov/vim-glsl', ft = 'glsl' }
	use { 'abhikjain360/wgsl.vim', ft = 'glsl' }
	-- use 'p00f/nvim-ts-rainbow'

end)
