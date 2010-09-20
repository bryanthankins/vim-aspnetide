" Copyright (C) 2010 Bryant Hankins.
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software Foundation,
" Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
" 
" Author: Bryant Hankins (bryanthankins [at] gmail [dot] com)
" URL:		http://www.bryanthankins.com
" Version:	0.9
" Last Change:  2010 Sept 18
" 
" aspnetide : 
" A Plugin that turns vim into an asp.net IDE! 

" Features :
" "OnlineDoc - F1"
"   Jump to online help based on selected word: F1 or <leader>H
" "BuildSolution - <leader>B"
"   Find a solution file for the project and build. Errors shown in quickfix: <leader>B
" "AlternateFile - <leader>A"
"   Navigate to alternate files (ASPX <-> code-behind): <leader>A
" "ShowAppInBrowser - F5"
"   Run app in local webserver and navigate to selected page: F5 or <leader>R
" Install : 
"  Copy this file to vimfiles/plugin/aspnetide.vim.  
"
" Notes :
"  -For those new to vim, <leader> is typically a backslash on windows boxes
"  -Alternate file navigation is ASP.NET webforms specific (I'll try to add MVC support soon)
"  -You *may* need to have VS.NET installed for ShowAppInBrowser to work. Not sure if 
"  the local web server gets installed with just the .net fromework.
"  -The build and run features only work on windows. With a few tweaks this could work nice
"  for mono on linux though...
"
"  TO DO :
"  -Integrate mono xsp when running on non-windows
"  -Intgrate mono xbuild when running on non-windows
"  -More elegantly search for msbuild and webdev.exe
"  
"
"  Enjoy! Feedback and patches are welcome.

if (exists("g:loaded_aspnetide"))
  finish
endif
let g:loaded_aspnetide= 1

"map keys to new functions
map <silent> <F1> :call <SID>OnlineDoc()<CR>
imap <silent> <F1> <ESC>:call <SID>OnlineDoc()<CR>
map <silent> <leader>H :call <SID>OnlineDoc()<CR>
imap <silent> <leader>H <ESC>:call <SID>OnlineDoc()<CR>
map <silent> <leader>A :call <SID>AlternateFile()<CR>
imap <silent> <leader>A <ESC>:call <SID>AlternateFile()<CR>
map <silent> <leader>R :call <SID>ShowAppInBrowser()<CR>
imap <silent> <leader>R <ESC>:call <SID>ShowAppInBrowser()<CR>
map <silent> <F5> :call <SID>ShowAppInBrowser()<CR>
imap <silent> <F5> <ESC>:call <SID>ShowAppInBrowser()<CR>
map <silent> <leader>B :call <SID>BuildSolution()<CR>
imap <silent> <leader>B <ESC>:call <SID>BuildSolution()<CR>

function! s:AlternateFile()
    let currExt = expand('%:e') 
    if currExt == 'aspx' || currExt == 'ascx' 
        let path = expand('%:p').'.'
        let extensions = ['cs','vb']
        if !s:ReadableWithExt(path, extensions)
              echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
        endif
    elseif currExt == 'cs' || currExt == 'vb'
        let path = expand('%:p:r')
        let extensions = ['aspx','ascx']
        if !s:ReadableWithoutExt(path, extensions)
              echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
        endif
    else
        echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
    endif
endf

function! s:ReadableWithExt(path, extensions)
	for ext in a:extensions
		if filereadable(a:path.ext)
             exe 'w'
             exe 'e '.a:path.ext
			return 1
		endif
	endfor
	return 0
endf

function! s:ReadableWithoutExt(path, extensions)
	for ext in a:extensions
		if filereadable(a:path)
            exe 'w'
            exe 'e '.a:path
			return 1
		endif
	endfor
	return 0
endf

function! s:BuildSolution()
    let dotnet_sln = fnameescape(globpath(expand('%:p:h'), '*.sln'))
    " Search a few levels up to see if we can find the sln file
    if empty(dotnet_sln)
        let dotnet_sln  = fnameescape(globpath(expand('%:p:h:h'), '*.sln'))

        if empty(dotnet_sln)
            let dotnet_sln = fnameescape(globpath(expand('%:p:h:h:h'), '*.sln'))
            if empty(dotnet_sln)
                let dotnet_sln = fnameescape(globpath(expand('%:p:h:h:h:h'), '*.sln'))
            endif
        endif
    endif

    "let's check a couple logical places and hope you didn't install on the d drive...
    let foundsln = 0
    let foundmsbuild = 0
    let msbuildpaths = ['C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\MSBuild.exe', 'C:\\winnt\\Microsoft.NET\\Framework\\v4.0.30319\\MSBuild.exe', 'C:\\WINDOWS\\Microsoft.NET\\Framework\\v3.5\MSBuild.exe']
    for msbuild in msbuildpaths
        if filereadable(msbuild)
            let foundmsbuild = 1
            if filereadable(dotnet_sln) 
                let foundsln = 1
                exe 'w'
                " TO DO :pass in sln or proj path to msbuild rather than changing current dir
                exe 'cd '. fnamemodify(dotnet_sln, ':p:h') 
                exe 'set makeprg='.msbuild.'\ /nologo\ /v:q\ '
                mak
                cope
            endif
        endif
    endfor
    "add some messaging if things go bad
    if foundsln == 0
        echoh ErrorMsg | echo 'Could not find solution file.' | echoh None
    endif
    if foundmsbuild == 0
        echoh ErrorMsg | echo 'Could not find msbuild.' | echoh None
    endif
endf

"setup integrated help
function! s:OnlineDoc()
  let wordUnderCursor = expand("<cword>")
  let url = "http://social.msdn.microsoft.com/Search/en-US/?Query=" . wordUnderCursor
  let cmd = ":silent ! start " . url
  execute cmd
endfunction



"start local web server and browser
function! s:ShowAppInBrowser()
  "look in the most common places for the webserver. Let's hope you didn't
  "install to a non-standard place...
  let serverpaths = ['C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer20.exe', 'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer20.exe', 'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe','C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe']
  for path in serverpaths
      if filereadable(path)
          "Start server
          let cmdServer = "silent !start " . path . " /port:". strftime("%H%M") . " /path:" . expand('%:p:h')
          execute cmdServer
          "Start browser
          let cmdBrowser = ":silent ! start" . " http://localhost:". strftime("%H%M") . "/" . expand('%:p:t')
          execute cmdBrowser
          return 1
      endif
  endfor
  echoh ErrorMsg | echo 'Could not find local webserver.' | echoh None
  return 0
endfunction


