color elflord 
set number	" Show line numbers
set linebreak	" Break lines at word (requires Wrap lines)
set showbreak=+++	" Wrap-broken line prefix
set textwidth=100	" Line wrap (number of cols)
set showmatch	" Highlight matching brace
set visualbell	" Use visual bell (no beeping)
set hlsearch	" Highlight all search results
set smartcase	" Enable smart-case search
set ignorecase	" Always case-insensitive
set incsearch	" Searches for strings incrementally
set autoindent	" Auto-indent new lines
set shiftwidth=4	" Number of auto-indent spaces
set smartindent	" Enable smart-indent
set smarttab	" Enable smart-tabs
set softtabstop=4	" Number of spaces per Tab
"" Advanced
set ruler	" Show row and column ruler information
set undolevels=1000	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour

"" Allows Toggling between relative and absolute numbers with CTRL+n
function! NumberToggle()
  if(&relativenumber == 1)
    set number
    set rnu!
  else
    set relativenumber
  endif
endfunc
nnoremap <C-n> :call NumberToggle()<cr>


set rnu
set number
"" Set and unset relative line numbers depending on mode
autocmd InsertEnter * :set rnu!
autocmd InsertLeave * :set rnu
:au FocusLost * :set rnu!
:au FocusGained * :set relativenumber

"" Allows tabcompletion cycles
set wildmenu
" Brad wuz here
set mouse=a


