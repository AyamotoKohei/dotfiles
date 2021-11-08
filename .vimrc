" ==========================
" dein detup
" ==========================
let s:dein_dir = $HOME . '/.vim/bundle'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  " Load and cached toml
  " all plugins listed in toml
  call dein#load_toml(s:dein_dir . '/rc/dein.toml', {'lazy': 0})
  call dein#load_toml(s:dein_dir . '/rc/dein_lazy.toml', {'lazy': 1})
  call dein#end()
  call dein#save_state()
endif

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" ==========================
" 基本設定
" ==========================
set fenc=utf-8  " 文字コードをUTF-8に設定
set nobackup    " バックアップファイルを作らない
set noswapfile  " スワップファイルを作らない
set autoread    " 編集中のファイルが変更されたら自動で読み直す
set hidden      " バッファが編集中でもその他のファイルを開けるように
set showcmd     " 入力中のコマンドをステータスに表示する
set backspace=indent,eol,start  " 挿入モードでバックスペースで削除できるようにする
set ambiwidth=double  " 全角文字専用の設定
nnoremap <silent><C-e> :NERDTreeToggle<CR>
inoremap { {}<LEFT>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>
inoremap ` ``<LEFT>

" ==========================
" 表示設定
" ==========================
set noerrorbells  " エラーメッセージのときビープを鳴らさない
set number        " 行番号を表示
set virtualedit=onemore  " 行末の1文字先までカーソルを移動できるように
set smartindent   " インデントはスマートインデント
set showmatch     " 括弧入力時の対応する括弧を表示
set laststatus=2  " ステータスラインを常に表示
set wildmode=list:longest  " コマンドラインの補完
set cursorline    " カーソルラインをハイライト
"nnoremap j gj     " 折り返し時に表示行単位での移動できるようにする
"nnoremap k gk
syntax enable     " シンタックスハイライトの有効化
set background=dark
colorscheme iceberg
let g:lightline = {
      \ 'colorscheme': 'iceberg'
      \ }

" ==========================
" Tab系の設定
" ==========================
set list listchars=tab:\▸\-,trail:-,eol:↲ " 不可視文字を可視化
set expandtab     " Tab文字を半角スペースにする
set tabstop=4     " 行頭以外のTab文字の表示幅（スペースいくつ分）
set shiftwidth=4  " 行頭でのTab文字の表示幅

" ==========================
" 検索系
" ==========================
set ignorecase    " 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set smartcase     " 検索文字列に大文字が含まれている場合は区別して検索する
set incsearch     " 検索文字列入力時に順次対象文字列にヒットさせる
set wrapscan      " 検索時に最後まで行ったら最初に戻る
set hlsearch      " 検索語をハイライト表示
nmap <Esc><Esc> :nohlsearch<CR><Esc>  " ESC連打でハイライト解除

"--------------------------------------------
" vim-lsp settings
"--------------------------------------------
nmap gf :LspDefinition<CR> 
nmap gt :LspTypeDefinition<CR>
nmap gj :LspDeclaration<CR>
nmap gi :LspImplementation<CR>
nmap gr :LspReferences<CR>
nmap gF <C-o> " back from definition 
nmap gn :LspRename<CR>

"let g:lsp_settings_filetype_go = ['gopls']
"let g:lsp_diagnostics_enabled = 0 " disable linter error popups
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_text_edit_enabled = 1

"--------------------------------------------
" asyncomplete settings
"--------------------------------------------
let g:asyncomplete_auto_popup = 1

let g:asyncomplete_popup_delay = 200 
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
" imap <c-space> <Plug>(asyncomplete_force_refresh)
