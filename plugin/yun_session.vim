" Describe:	Save session before quit vim and restore session 
" Last Change:	2018-9-25
" Author:	neihaiyou
" License:	MIT, see the LICENSE file


if exists("g:vimquit")
    exec 'echo "g:vimquit has been exists!"'
    unlet g:vimquit
    exec 'source ' . expand('<sfile>')
    finish
endif

let g:vimquit = 0

if !exists("g:sessionPath") || !isdirectory(g:sessionPath)
    let g:sessionPath = $VIM . '\session'

    "if finddir('session', $VIM) == ''
    if !isdirectory(g:sessionPath)
	mkdir(g:sessionPath)	
    endif
endif

augroup vimopen
    autocmd! vimopen	

    autocmd VimEnter * call SessionRestore()
    "autocmd VimLeave * silent if s:vimquit == 0 | exec 'let s:vimquit=1' | call SaveSession() | endif
    autocmd VimLeave * if g:vimquit == 0 | exec 'let g:vimquit=1' | call SessionSave() | endif
augroup END


function! s:echoInfo(var, val, fname)
    " Is shell using cmd.exe?
    if fnamemodify(&shell, ':t:r') ==? 'cmd'
	exec '!echo '.a:var'>'.a:fname
	exec '!echo.'.a:val'>>'.a:fname
    else
	" 因为在bash中的nvim执行bash的命令会出错，所有当前已经在bash下
	" nvim中的shell设置为cmd.exe，以下命令始终不会被执行
	exec '!echo ' . "'" . a:var . "'" . '>' . a:fname
	exec '!echo -e ' . "'" . '\r\n' . a:val . "'" . '>>' . a:fname
    endif
endfunc

function! s:configInfoFile()
    let l:infofile = g:sessionPath . '\session_info.txt'
    if !exists("g:session_idx")
	if !filereadable(l:infofile)
	    call s:echoInfo('g:session_idx', '0', l:infofile)
	endif
	let l:info_list = readfile(l:infofile)
	exec 'let ' . l:info_list[0] . '=' . l:info_list[1]
    endif
    return l:infofile
endfunc

function! ReadShada()
    let l:fname = expand('~\AppData\Local\nvim-data\shada\main.shada')
    let l:mpack = readfile(l:fname, 'b')
    let l:shada_obj = msgpackparse(mpack)
    return l:shada_obj
endfunc

function! Setopts(name, val)
    if !exists(a:name)
	exec 'let ' . a:name . '=' string(a:val)
    endif
endfunc


function! SessionSave()
    let l:infofile = s:configInfoFile()

    if exists("g:session_idx")
	let g:session_idx += 1
	if g:session_idx >= 10
	    let g:session_idx = 1
	endif
	call s:echoInfo('g:session_idx', string(g:session_idx), l:infofile)

	let l:filePath = g:sessionPath . '\session' . string(g:session_idx) . '.vim'

	" NERDTree doesn't support session, so close before saving
	exec 'NERDTreeClose'
	exec 'mksession! ' . l:filePath
	exec 'NERDTreeToggle'
    endif
endfunc

function! SessionRestore()
    call s:configInfoFile()
    
    if exists("g:session_idx") && g:session_idx > 0
	let l:idx = g:session_idx
	while l:idx < 10
	    let l:filePath = g:sessionPath . '\session' . string(l:idx) . '.vim'
	    if filereadable(l:filePath)
		exec 'source ' . l:filePath
		exec 'NERDTreeClose'
		exec 'NERDTreeToggle' | wincmd p
		break
	    endif
	    let l:idx += 1
	endwhile
    endif
endfunc

function! SessionDelete()
    if exists("g:session_idx")
	let l:idx = g:session_idx

	while l:idx < 10
	    let l:fnameAbs = g:sessionPath . '\session' . string(l:idx) . '.vim'
	    if filereadable(l:fnameAbs)
		exec 'del /F/S ' . l:fnameAbs
	    endif
	    let l:idx += 1
	endwhile

	let fnameAbs = g:sessionPath . '\session_info.txt'
	if filereadable(l:fnameAbs)
	    exec 'del /F/S ' . l:fnameAbs 
	endif
    endif
endfunc

