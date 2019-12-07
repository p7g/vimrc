scriptencoding utf-8
set fileencoding=utf-8 termencoding=utf-8 encoding=utf-8

let s:haswin = has('win32') || has('win64')

" set shell
if s:haswin
  set shell=powershell
endif

if s:haswin
  let s:pathsep = '\'
else
  let s:pathsep = '/'
endif

" create a directory if it doesn't already exist
function! s:assertdir(path)
  if !isdirectory(a:path)
    let l:path = shellescape(a:path)
    if s:haswin
      silent execute '!New-Item -Path "' . l:path . '" -Type Directory'
    else
      silent execute '!mkdir -p ' . l:path
    endif
  endif
endfunction

function! s:joinpaths(...)
  return join(a:000, s:pathsep)
endfunction

" try to figure out where the .vim equivalent directory is
let $vimdir = resolve(expand('<sfile>:p:h'))
if $vimdir ==# $HOME
  if s:haswin
    let s:path = s:joinpaths($HOME, 'vimfiles')
  else
    let s:path = s:joinpaths($HOME, '.vim')
  endif
  call s:assertdir(s:path)
  let $vimdir = s:path
endif

for s:p in ['undo', 'backups', 'tmp']
  call s:assertdir(s:joinpaths($vimdir, s:p))
endfor

let s:deinroot = s:joinpaths($HOME, '.cache', 'dein')
let s:deindir = s:joinpaths(s:deinroot, 'repos', 'github.com', 'Shougo', 'dein.vim')
" install dein if it's not installed already
if !isdirectory(glob(s:deinroot))
  " check for missing dependencies
  let s:missing_deps = []
  for s:dep in ['git', 'node', 'npm']
    if !executable(s:dep)
      call add(s:missing_deps, s:dep)
    endif
  endfor
  if len(s:missing_deps)
    echoerr 'Missing dependencies: ' . join(s:missing_deps, ', ')
    finish
  endif

  echom 'Installing dein'
  execute '!git clone https://github.com/Shougo/dein.vim ' . s:deindir
endif

let g:colorschemes = [
      \ 'dim13/gocode.vim',
      \ 'pgdouyon/vim-yin-yang',
      \ 'sansbrina/vim-garbage-oracle',
      \ 'pbrisbin/vim-colors-off',
      \ 'owickstrom/vim-colors-paramount',
      \ 'p7g/vim-bow-wob',
      \ 'jeffkreeftmeijer/vim-dim',
      \ 'noahfrederick/vim-noctu',
      \ 'fenetikm/falcon',
      \ 'challenger-deep-theme/vim',
      \ 'djjcast/mirodark',
      \ 'junegunn/seoul256.vim',
      \ 'rakr/vim-two-firewatch',
      \ 'whatyouhide/vim-gotham',
      \ ]

let g:plugins = [
      \ 'tpope/vim-sleuth',
      \ 'tpope/vim-surround',
      \ 'tpope/vim-fugitive',
      \ 'tpope/vim-rsi',
      \ 'tpope/vim-dadbod',
      \ 'tpope/vim-repeat',
      \ 'tpope/vim-abolish',
      \ 'sheerun/vim-polyglot',
      \ 'editorconfig/editorconfig-vim',
      \ ['junegunn/fzf', {'build': './install --all'}],
      \ 'junegunn/fzf.vim',
      \ 'kchmck/vim-coffee-script',
      \ 'tommcdo/vim-lion',
      \ ['neoclide/coc.nvim', {'rev': 'release'}],
      \ 'sbdchd/neoformat',
      \ 'vim-perl/vim-perl6',
      \ 'gu-fan/riv.vim',
      \ 'gu-fan/InstantRst',
      \ ]

let &runtimepath .= ',' . s:deindir
if dein#load_state(s:deinroot)
  call dein#begin(s:deinroot)
  call dein#add(s:deindir)

  for s:plugin in g:colorschemes + g:plugins
    if type(s:plugin) == v:t_list
      let [s:name, s:options] = s:plugin
      call dein#add(s:name, s:options)
    else
      call dein#add(s:plugin)
    endif
  endfor

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif

function! CleanPlugins()
  for l:path in dein#check_clean()
    echom 'Deleting ' . l:path
    call delete(fnameescape(l:path), 'rf')
  endfor
endfunction
command! CleanPlugins :call CleanPlugins()

let s:coc_extensions = [
      \ 'coc-json',
      \ 'coc-tsserver',
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-python',
      \ 'coc-emmet',
      \ 'coc-eslint',
      \ 'coc-git',
      \ 'coc-vimlsp',
      \ 'coc-prettier',
      \ 'coc-tabnine',
      \ 'coc-rls',
      \ 'coc-clock',
      \ 'coc-terminal',
      \ 'coc-calc',
      \ ]

function! InstallCocExtensions()
  for l:extension in s:coc_extensions
    execute 'CocInstall ' . l:extension
  endfor
endfunction

filetype plugin indent on
syntax on

""" colorscheme configuration
set background=light
colorscheme seoul256-light

if has('gui') && !has('nvim')
  set guifont=IBMPlexMono-Text:h19
endif

set autoindent
set autoread   " reload files when changed externally
set backupdir=$vimdir/backups
set belloff=all
set colorcolumn=160
set directory=$vimdir/tmp
set expandtab
set exrc
set grepprg=rg\ --vimgrep
set guioptions=
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:»\ ,nbsp:~,trail:·,space:·,eol:¬,extends:…,precedes:…
set matchtime=1
set nohidden
set nospell
set novisualbell
set number
set numberwidth=4
set relativenumber
set secure
set shiftround
set shiftwidth=2
set signcolumn=yes
set smartcase
set smartindent
set splitbelow
set splitright
set tabstop=4
set termguicolors
set undodir=$vimdir/undo
set undofile
set updatetime=300
set wrap
set writebackup

set statusline=%#LineNr#  " match number column hightlighting
set statusline+=\         " space before any text
set statusline+=%t        " filename, no directory
set statusline+=\         " space
set statusline+=%m        " modified flag
set statusline+=%r        " readonly flag
set statusline+=%h        " helpfile flag
set statusline+=%w        " preview window flag
set statusline+=%q        " quickfix window flag
set statusline+=\ %{coc#status()}
set statusline+=%{get(b:,'coc_current_function','')}
set statusline+=%=        " switch to right side
set statusline+=%P        " percentage through file
set statusline+=\         " space after percentage

let g:mapleader = '\'
let g:maplocalleader = '|'

" remap hjkl for Colemak (without using other keys)
noremap h k
noremap k j
noremap j h
noremap <C-w>h <C-w>k
noremap <C-w>k <C-w>j
noremap <C-w>j <C-w>h

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" ' . shellescape(<q-args>) . '| tr -d "\017"', 1, <bang>0)
noremap <silent> <C-p> :FZF<CR>

" press enter or shift enter to add a new line above/below
nnoremap <CR> o<Esc>
nnoremap <S-CR> O<Esc>

" resize split with ctrl-arrows
nnoremap <silent> <C-Up> :resize +5<CR>
nnoremap <silent> <C-Down> :resize -5<CR>
nnoremap <silent> <C-Left> :vertical resize -5<CR>
nnoremap <silent> <C-Right> :vertical resize +5<CR>

" use magic regex
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/
nnoremap :g/ :g/\v
nnoremap :g// :g//

" <leader>ts removes trailing whitespace
nnoremap <silent> <leader>ts :%s/\s\+$//ge<CR>

" clear search highlight with <leader>space
nnoremap <silent> <leader><space> :let @/=""<CR>

" o/O
"
" Start insert mode with [count] blank lines. The default behaviour repeats
" the insertion [count] times, which is not so useful.
"
" Credit: https://stackoverflow.com/a/27820229
function! s:NewLineInsertExpr(isUndoCount, command)
  if !v:count
    return a:command
  endif

  let l:reverse = {'o': 'O', 'O': 'o'}
  " First insert a temporary '$' marker at the next line (which is necessary
  " to keep the indent from the current line), then insert <count> empty lines
  " in between. Finally, go back to the previously inserted temporary '$' and
  " enter insert mode by substituting this character.
  " Note: <C-\><C-n> prevents a move back into insert mode when triggered via
  " |i_CTRL-O|.
  return (a:isUndoCount && v:count ? "\<C-\>\<C-n>" : '') .
        \ a:command . "$\<Esc>m`" .
        \ v:count . l:reverse[a:command] . "\<Esc>" .
        \ 'g``"_s'
endfunction
nnoremap <silent> <expr> o <SID>NewLineInsertExpr(1, 'o')
nnoremap <silent> <expr> O <SID>NewLineInsertExpr(1, 'O')


" diff the current state of a buffer with the most recently saved version of
" the file
function! s:DiffWithSaved()
  let l:filetype = &filetype
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  execute 'setlocal ' .
        \ 'buftype=nofile ' .
        \ 'bufhidden=wipe ' .
        \ 'nobuflisted ' .
        \ 'noswapfile ' .
        \ 'readonly ' .
        \ 'filetype=' . l:filetype
endfunction
command! DiffWithSaved call s:DiffWithSaved()

" <leader>b shows current buffers
nnoremap <leader>b :buffers<CR>

" <leader>c shows positional stats
nnoremap <leader>c g<C-g>

" open vimrc quickly
nnoremap <leader>vrc :vsplit $MYVIMRC<CR>
nnoremap <leader>src :split  $MYVIMRC<CR>
nnoremap <leader>rc  :edit   $MYVIMRC<CR>
" source vimrc quickly
nnoremap <leader>st :source $MYVIMRC<CR>

function! SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
command! SynGroup :call SynGroup()

" automatically change to non-relative numbers when not active buffer
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" filetype stuff

augroup filetype_javascript
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType javascript noremap <localleader>r :w !node -<CR>
augroup END

augroup filetype_php
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType php noremap <localleader>r :w !php -r
        \ '$f = file_get_contents("php://stdin");'
        \ . '$pos = strpos($f, "<?php");'
        \ . '$code = $pos === 0 ? substr($f, $pos + strlen("<?php")) : $f;'
        \ . 'eval($code);'<CR>
augroup END

augroup filetype_python
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType python noremap <localleader>r :w !python -<CR>
augroup END

augroup filetype_ruby
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType ruby noremap <localleader>r :w !ruby -<CR>
augroup END

augroup filetype_julia
  autocmd!
  " run the current file/selection with <localleader>r
  autocmd FileType julia noremap <localleader>r :w !julia<CR>
augroup END

augroup comment_textwidth
  autocmd!
  " set the textwidth to the value of colorcolumn when in a comment
  autocmd FileType markdown,rst let g:dontAdjustTextWidth = 1
  autocmd TextChanged,TextChangedI * :call AdjustTextWidth()
augroup END

let g:comment_width = 80
function! AdjustTextWidth() abort
  if exists('g:dontAdjustTextWidth')
    return
  endif
  let l:syn_element = synIDattr(synID(line('.'), col('.') - 1, 1), 'name')
  let &textwidth = syn_element =~? 'comment' ? g:comment_width : 0
endfunction

" coc config
nmap <leader>d :CocList diagnostics<CR>
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>a :<C-u>CocList outline<CR>
nmap <leader>q :<C-u>CocList -I symbols<CR>
nnoremap <silent> K :call <SID>show_documentation()<CR>
xmap <silent> <leader>f <Plug>(coc-format-selected)
nmap <silent> <leader>f :call CocAction('format')<CR>
nmap <silent> <C-k> <Plug>(coc-diagnostic-info)
nmap <silent> <leader>clock :ClockToggle<CR>
nmap <silent> <leader>calc <Plug>(coc-calc-result-replace)
nmap <silent> <leader>tt <Plug>(coc-terminal-toggle)
nmap <silent> <leader>td :CocCommand terminal.Destroy<CR>

" augroup cocsettings
"   autocmd!
"   autocmd CursorHold * silent call CocActionAsync('highlight')
" augroup END

function! s:show_documentation()
  if index(['vim', 'help'], &filetype) >= 0
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

let s:clockOn = 0
function! s:toggleClock()
  if s:clockOn
    CocCommand clock.disable
  else
    CocCommand clock.enable
  endif
  let s:clockOn = !s:clockOn
endfunction
command! ClockToggle call s:toggleClock()

" FZF mappings
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>B :Buffers<CR>
nnoremap <silent> <leader>Gf :GFiles<CR>
nnoremap <silent> <leader>G? :GFiles?<CR>
nnoremap <silent> <leader>Gb :BCommits<CR>
nnoremap <silent> <leader>Gc :Commits<CR>
nnoremap <silent> <leader>H :History:<CR>

" rst stuff
function! RSTMakeTitle(level) abort
  let l:underline_char = ['=', '=', '-', '\~', '#', '$', '+'][a:level]
  normal yyp
  execute 's/./' . l:underline_char . '/g'
  let @/=''
  normal! o
  normal! o
endfunction

augroup filetype_rst
  autocmd!

  autocmd filetype rst nnoremap <leader>t :<C-U>call RSTMakeTitle(v:count)<CR>
augroup END

" neoformat config
let g:neoformat_python_black = {
      \ 'exe': 'tan',
      \ 'args': ['-'],
      \ 'stdin': 1,
      \ 'no_append': 1,
      \ }

let g:neoformat_enabled_python = ['black']

autocmd BufRead *.variables set filetype=less
autocmd BufRead .eslintrc set filetype=json5
