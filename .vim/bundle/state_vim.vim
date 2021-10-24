if g:dein#_cache_version !=# 410 || g:dein#_init_runtimepath !=# '/home/ayamoto/.vim/bundle/repos/github.com/Shougo/dein.vim/,/home/ayamoto/.vim,/var/lib/vim/addons,/etc/vim,/usr/share/vim/vimfiles,/usr/share/vim/vim81,/usr/share/vim/vimfiles/after,/etc/vim/after,/var/lib/vim/addons/after,/home/ayamoto/.vim/after' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#min#_load_cache_raw(['/home/ayamoto/.vimrc', '/home/ayamoto/.vim/bundle/rc/dein.toml', '/home/ayamoto/.vim/bundle/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/home/ayamoto/.vim/bundle'
let g:dein#_runtime_path = '/home/ayamoto/.vim/bundle/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/home/ayamoto/.vim/bundle/.cache/.vimrc'
let &runtimepath = '/home/ayamoto/.vim/bundle/repos/github.com/Shougo/dein.vim/,/home/ayamoto/.vim,/var/lib/vim/addons,/etc/vim,/usr/share/vim/vimfiles,/home/ayamoto/.vim/bundle/repos/github.com/Shougo/dein.vim,/home/ayamoto/.vim/bundle/.cache/.vimrc/.dein,/usr/share/vim/vim81,/home/ayamoto/.vim/bundle/.cache/.vimrc/.dein/after,/usr/share/vim/vimfiles/after,/etc/vim/after,/var/lib/vim/addons/after,/home/ayamoto/.vim/after'
filetype off
