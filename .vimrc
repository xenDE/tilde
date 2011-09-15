set nocompatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

if has("autocmd")
    " Jump to the last position when reopening a file
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif

    " Uncomment the following to have Vim load indentation rules according to the
    " detected filetype. Per default Debian Vim only load filetype specific
    " plugins.
    filetype indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd     " Show (partial) command in status line.
set showmatch   " Show matching brackets.
set ignorecase  " Do case insensitive matching
set smartcase   " Do smart case matching
set incsearch   " Incremental search
set autowrite   " Automatically save before commands like :next and :make
set hidden      " Hide buffers when they are abandoned
"set mouse=a     " Enable mouse usage (all modes) in terminals

" Backspace behaving as in other editors
set backspace=indent,eol,start

" Press F2 before pasting text to avoid crazy indentation
set pastetoggle=<F2>

" Indentation/tabs
autocmd FileType * set tabstop=4|set shiftwidth=4|set expandtab
autocmd FileType make set tabstop=8|set shiftwidth=8|set noexpandtab
nmap <silent> ]] :let &tabstop += 1 <CR> :echo 'tabstop =' &tabstop <CR>
nmap <silent> [[ :let &tabstop -= &tabstop > 1 ? 1 : 0 <CR> :echo 'tabstop =' &tabstop <CR>
nmap <silent> <S-t> :set expandtab! | if &expandtab | retab | echo 'spaces' | else | retab! | echo 'tabs' | endif<CR>

" Replace CR with LF
noremap <C-n> :%s/\r/\r/g <CR>

" Sort words
command! -nargs=0 -range SortWords call VisualSortWords()

function! VisualSortWords()
    let rv = @"
    let rt = getregtype('"')
    try
        norm! gvd
        call setreg('"', join(sort(split(@")), ' '), visualmode()[0])
        norm! P
    finally
        call setreg('"', rv, rt)
    endtry
endfunction

" Unicode
set fileencodings=utf-8,latin1,ascii

" Temporary files
set backupdir=~/.vimtmp,.
set directory=~/.vimtmp,.
