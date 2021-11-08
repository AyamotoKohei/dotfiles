if g:dein#_cache_version !=# 410 || g:dein#_init_runtimepath !=# '/c/Users/ak29280/.vim/bundle/repos/github.com/Shougo/dein.vim/,/c/Users/ak29280/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim82,/usr/share/vim/vimfiles/after,/c/Users/ak29280/.vim/after' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#min#_load_cache_raw(['/c/Users/ak29280/.vimrc', '/c/Users/ak29280/.vim/bundle/rc/dein.toml', '/c/Users/ak29280/.vim/bundle/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/c/Users/ak29280/.vim/bundle'
let g:dein#_runtime_path = '/c/Users/ak29280/.vim/bundle/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/c/Users/ak29280/.vim/bundle/.cache/.vimrc'
let &runtimepath = '/c/Users/ak29280/.vim/bundle/repos/github.com/Shougo/dein.vim/,/c/Users/ak29280/.vim,/usr/share/vim/vimfiles,/c/Users/ak29280/.vim/bundle/repos/github.com/Shougo/dein.vim,/c/Users/ak29280/.vim/bundle/.cache/.vimrc/.dein,/usr/share/vim/vim82,/c/Users/ak29280/.vim/bundle/.cache/.vimrc/.dein/after,/usr/share/vim/vimfiles/after,/c/Users/ak29280/.vim/after'
filetype off
