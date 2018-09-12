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
	while l:cnt < l:buf.cnt
	    exe 'bw ' . string(l:buf.unamelisted.bufnr[l:cnt])
	    let l:cnt += 1
	endwhile
    endif
endfunc
