-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/niil/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/niil/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/niil/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/niil/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/niil/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["BetterLua.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/BetterLua.vim",
    url = "https://github.com/euclidianAce/BetterLua.vim"
  },
  ["ag.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/ag.vim",
    url = "https://github.com/rking/ag.vim"
  },
  ["async.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/async.vim",
    url = "https://github.com/prabirshrestha/async.vim"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  ["ctrlp.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/ctrlp.vim",
    url = "https://github.com/kien/ctrlp.vim"
  },
  fzf = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["ghcmod-vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/ghcmod-vim",
    url = "https://github.com/eagletmt/ghcmod-vim"
  },
  ["haskell-vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/haskell-vim",
    url = "https://github.com/neovimhaskell/haskell-vim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/lspkind-nvim",
    url = "https://github.com/onsails/lspkind-nvim"
  },
  ["monokai.nvim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/monokai.nvim",
    url = "https://github.com/tanvirtin/monokai.nvim"
  },
  nerdtree = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/nerdtree",
    url = "https://github.com/scrooloose/nerdtree"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  semshi = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/semshi",
    url = "https://github.com/numirias/semshi"
  },
  ["swift.vim"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/swift.vim",
    url = "https://github.com/keith/swift.vim"
  },
  syntastic = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/syntastic",
    url = "https://github.com/vim-syntastic/syntastic"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-cool"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-cool",
    url = "https://github.com/romainl/vim-cool"
  },
  ["vim-gitgutter"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-gitgutter",
    url = "https://github.com/airblade/vim-gitgutter"
  },
  ["vim-lsp"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-lsp",
    url = "https://github.com/prabirshrestha/vim-lsp"
  },
  ["vim-markdown"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-markdown",
    url = "https://github.com/plasticboy/vim-markdown"
  },
  ["vim-pbxproj"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-pbxproj",
    url = "https://github.com/cfdrake/vim-pbxproj"
  },
  ["vim-ruby"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-ruby",
    url = "https://github.com/vim-ruby/vim-ruby"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-startify",
    url = "https://github.com/mhinz/vim-startify"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator",
    url = "https://github.com/christoomey/vim-tmux-navigator"
  },
  ["vim-tmux-runner"] = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vim-tmux-runner",
    url = "https://github.com/christoomey/vim-tmux-runner"
  },
  vimpeccable = {
    loaded = true,
    path = "/Users/niil/.local/share/nvim/site/pack/packer/start/vimpeccable",
    url = "https://github.com/svermeulen/vimpeccable"
  }
}

time([[Defining packer_plugins]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
