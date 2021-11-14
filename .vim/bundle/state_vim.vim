if g:dein#_cache_version !=# 410 || g:dein#_init_runtimepath !=# '/Users/kohei.a/.vim/bundle/repos/github.com/Shougo/dein.vim/,/Users/kohei.a/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim82,/usr/share/vim/vimfiles/after,/Users/kohei.a/.vim/after' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#min#_load_cache_raw(['/Users/kohei.a/.vimrc', '/Users/kohei.a/.vim/bundle/rc/dein.toml', '/Users/kohei.a/.vim/bundle/rc/dein_lazy.toml'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/Users/kohei.a/.vim/bundle'
let g:dein#_runtime_path = '/Users/kohei.a/.vim/bundle/.cache/.vimrc/.dein'
let g:dein#_cache_path = '/Users/kohei.a/.vim/bundle/.cache/.vimrc'
let &runtimepath = '/Users/kohei.a/.vim/bundle/repos/github.com/Shougo/dein.vim/,/Users/kohei.a/.vim,/usr/share/vim/vimfiles,/Users/kohei.a/.vim/bundle/repos/github.com/Shougo/dein.vim,/Users/kohei.a/.vim/bundle/.cache/.vimrc/.dein,/usr/share/vim/vim82,/Users/kohei.a/.vim/bundle/.cache/.vimrc/.dein/after,/usr/share/vim/vimfiles/after,/Users/kohei.a/.vim/after'
