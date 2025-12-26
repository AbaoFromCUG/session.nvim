let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Documents/plugins/session.nvim
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +7 ~/Documents/plugins/session.nvim/plugin/session.lua
badd +10 ~/Documents/plugins/session.nvim/lua/session.lua
badd +26 ~/Documents/plugins/session.nvim/README.md
argglobal
%argdel
edit ~/Documents/plugins/session.nvim/README.md
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/Documents/plugins/session.nvim/lua/session.lua
setlocal foldmethod=manual
setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=99
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
silent! normal! zE
sil! 18,20fold
sil! 16,21fold
sil! 15,22fold
sil! 14,23fold
sil! 24,27fold
sil! 13,31fold
sil! 11,32fold
sil! 9,35fold
sil! 7,36fold
sil! 3,36fold
sil! 48,54fold
sil! 45,55fold
sil! 42,59fold
sil! 38,59fold
sil! 67,71fold
sil! 65,73fold
sil! 84,86fold
sil! 83,87fold
sil! 89,91fold
sil! 88,92fold
sil! 82,96fold
sil! 80,97fold
sil! 77,102fold
sil! 75,102fold
sil! 108,110fold
sil! 112,114fold
sil! 106,116fold
sil! 104,116fold
sil! 63,116fold
sil! 124,127fold
sil! 118,127fold
sil! 61,127fold
sil! 129,131fold
let &fdl = &fdl
3
sil! normal! zo
7
sil! normal! zo
9
sil! normal! zo
11
sil! normal! zo
13
sil! normal! zo
let s:l = 25 - ((17 * winheight(0) + 10) / 21)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 25
normal! 092|
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
