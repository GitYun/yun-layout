" Describe:	在normal模式下，使用<Tab>按键切换buffer或Tab
" Last Change:	2018-9-25
" Author:	neihaiyou
" License:	MIT, see the LICENSE file


if !exists("s:layout_cmd_loaded")
    " 打开一个与当前相同的新标签页
    nmap <A-t> :tab split<CR>
    nmap tl :tabl<CR>
    nmap tf :tabfirst<CR>
    nnoremap <unique> <silent> <Tab> :call TabMap('n')<CR>
    nnoremap <unique> <silent> <C-Tab> :call TabMap('p')<CR>
    nmap tc :tabclose<CR>
    nmap to :tabonly<CR>

    let s:layout_cmd_loaded = 1
    exec 'au FuncUndefined TabMap* source ' . expand('<sfile>')
    finish
endif

if exists("g:layout_loaded")
    finish
endif
let g:layout_loaded = 1

function! s:getBufCnt()
    let buf = {"listed": 0, "uname": 0, "unamelisted": {"cnt": 0, "bufnr":[]}}
    let info = 0

    for l:info in getbufinfo()
	if l:info.listed == 1
	    let l:buf.listed += 1
	endif
	if l:info.name == ""
	    let l:buf.uname += 1
	endif
	if l:info.listed == 1 && l:info.name == ""
	    let l:buf.unamelisted.cnt += 1
	endif
    endfor

    return l:buf
endfunc

" {{{1 function! TabMap(np)
function! TabMap(np)
    let l:cnt = tabpagenr('$')

    if l:cnt > 1
	if a:np ==# 'n'
	    exe "tabn"
	elseif a:np ==# 'p'
	    exe "tabp"
	endif
    elseif l:cnt == 1
	let l:buf = s:getBufCnt()

	if l:buf.listed > 1
	    if a:np ==# 'n'
		exe ":bn!" | redraw
	    elseif a:np ==# 'p'
		exe ":bp!" | redraw
	    endif
	endif

	let l:cnt = 0
	while l:cnt < l:buf.unamelisted.cnt
	    exe 'bw ' . string(l:buf.unamelisted.bufnr[l:cnt])
	    let l:cnt += 1
	endwhile
    endif
endfunc

