" aspnetide.vim: A Plugin that turns vim into an asp.net IDE! 
" Author: Bryant Hankins (bryanthankins [at] gmail [dot] com)
" URL:	http://www.vim.org/scripts/script.php?script_id=3243
" Version:	0.9

if (exists("g:loaded_aspnetide"))
  finish
endif
let g:loaded_aspnetide= 1

"map keys to new functions
map <silent> <F1> :call <SID>ASPDoc()<CR>
imap <silent> <F1> <ESC>:call <SID>ASPDoc()<CR>
map <silent> <leader>H :call <SID>ASPDoc()<CR>
imap <silent> <leader>H <ESC>:call <SID>ASPDoc()<CR>
map <silent> <leader>A :call <SID>ASPAltFile()<CR>
imap <silent> <leader>A <ESC>:call <SID>ASPAltFile()<CR>
map <silent> <leader>R :call <SID>ASPRun()<CR>
imap <silent> <leader>R <ESC>:call <SID>ASPRun()<CR>
map <silent> <F5> :call <SID>ASPRun()<CR>
imap <silent> <F5> <ESC>:call <SID>ASPRun()<CR>
map <silent> <leader>B :call <SID>ASPBuild()<CR>
imap <silent> <leader>B <ESC>:call <SID>ASPBuild()<CR>
map <silent> <leader>G :call <SID>ASPGoTo()<CR>
imap <silent> <leader>G <ESC>:call <SID>ASPGoTo()<CR>

function! s:ASPAltFile()
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

function! s:ASPGoTo()
    let currFileMatch = expand('<cword>:r').'.'.expand('%:e')
    let currSearchPath = expand('%:p:h:h:h').'\**'
    let fileToFind = findfile(currFileMatch,currSearchPath)
    if filereadable(fileToFind)
        exe 'w'
        exe 'e '.fileToFind
    else
        echoh ErrorMsg | echo 'Could not find file.' | echoh None
    endif
endf


function! s:ASPBuild()
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
function! s:ASPDoc()
  let wordUnderCursor = expand("<cword>")
  let url = "http://social.msdn.microsoft.com/Search/en-US/?Query=" . wordUnderCursor
  let cmd = ":silent ! start " . url
  execute cmd
endfunction



"start local web server and browser
function! s:ASPRun()
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


