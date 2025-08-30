" SETS
    "term
    set bg=dark
    "set limit oldfiles ls
        set viminfo='15
    " colorscheme
        colorscheme default
    " Disable compatibility with vi which can cause unexpected issues.
        set nocompatible
    " Enable type file detection. Vim will be able to try to detect the type of file in use.
        filetype on
    " Enable plugins and load plugin for the detected file type.
        filetype plugin on
    " Load an indent file for the detected file type.
        filetype indent on
    " setnumbersrelative
        set number
        set relativenumber
    " syntaxhl
        syntax on
    " hlsearch
        set hlsearch
    "cursorline/column
        set cursorline
        set cursorcolumn
    " Set shift width to 4 spaces
        set shiftwidth=4
    " Show file stats
        set ruler
    " Blink cursor on error instead of beeping
        set visualbell
    " Encoding
        set encoding=utf-8
    " Show color column at 80 characters width, visual reminder of keepingcode line within a popular line width.
        set colorcolumn=124
    " linewrapping
        set nowrap
    " formatting
        set expandtab
        set tabstop=4
    " wildmenu
        set wildmenu
        set wildmode=list,longest:full
        set wildignore=.git,*.swp,*/tmp/*
	" mouse
        set mouse=
        set ttymouse= 
    " persistentundo
        set undofile
        set undodir=~/.vim/undo
" KEYMAPS
    " reload vimrc
        map <leader>in :source ~/.vim/.vimrc <CR>
    " undo tree
        map <leader>u :undolist <CR>
    " leader        
        let mapleader = ' '
    " copy to sytem clipboard
        map <leader>y "+y
    " write
        map <leader>wc :w <CR>
    " write all
        map <leader>wa :wa<CR>
    " quitting
        " quit 
            map <leader>qq :q <CR>
        " quit no save
            map <leader>QQ :q!<CR>
        " close buffer
            map <leader>bd :bd<CR>
        " force close buffer
            map <leader>BD :bd!<CR> 
        " close all buffers
            map <leader>bx :%bd<CR>
        " write all & quit
            map <leadev>wq :wa<CR><BAR>:q<CR>
    " file management
        " new files
            " new full window
                map <leader>en :enew<CR>
            " new vertical split
                map <leader>sv :vnew<CR>
            " new horizontal split
                map <leader>sb :new<CR>
        " Netrw
            map <leader>f :Ex<CR>
        " oldfiles
            map <leader>pb :browse oldfiles<CR>
        " open buffers
            map <leader>b :buffers<CR>:buffer<Space>
    " quick access files
        " vimrc
            map <leader>vr :e ~/.vimrc<CR>
        " tmux.conf
            map <leader>tm :e ~/.config/tmux/tmux.conf <CR>
        " bashaliases
            map <leader>ba :e ~/Scripts/bashaliases.sh <CR>
        " bashrc
            map <leader>br :e ~/.bashrc <CR>
    " utils
        " chmod in editor
            map <leader>x :!chmod +x %<CR>     
        " resource shell
            map <leader>rs :!source ~/.zshrc %<CR>

    " splits management
            map <leader>h <C-w>h 
            map <leader>j <C-w>j
            map <leader>k <C-w>k             
            map <leader>l <C-w>l




filetype indent off
