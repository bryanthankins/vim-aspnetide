" aspnetide.vim: A Plugin that turns vim into an asp.net IDE! 
" Author: Bryant Hankins (bryanthankins [at] gmail [dot] com)
" URL:	http://www.vim.org/scripts/script.php?script_id=3243
" Version:	0.9

if (exists("g:loaded_aspnetide"))
  finish
endif
let g:loaded_aspnetide= 1

"map keys to new functions
"nmenomic is A for ASP plus do function keys like asp.net devs expect
map <silent> <F1> :call <SID>ASPHelp()<CR>
imap <silent> <F1> <ESC>:call <SID>ASPHelp()<CR>
map <silent> <leader>ah :call <SID>ASPHelp()<CR>
imap <silent> <leader>ah <ESC>:call <SID>ASPHelp()<CR>
map <silent> <leader>af :call <SID>ASPAltFile(0)<CR>
imap <silent> <leader>af <ESC>:call <SID>ASPAltFile(0)<CR>
map <silent> <leader>aw :call <SID>ASPAltFile(1)<CR>
imap <silent> <leader>aw <ESC>:call <SID>ASPAltFile(1)<CR>
map <silent> <leader>ar :call <SID>ASPRun()<CR>
imap <silent> <leader>ar <ESC>:call <SID>ASPRun()<CR>
map <silent> <F5> :call <SID>ASPRun()<CR>
imap <silent> <F5> <ESC>:call <SID>ASPRun()<CR>
map <silent> <leader>ab :call <SID>ASPBuild()<CR>
imap <silent> <leader>ab <ESC>:call <SID>ASPBuild()<CR>
map <silent> <leader>ag :call <SID>ASPGoTo()<CR>
imap <silent> <leader>ag <ESC>:call <SID>ASPGoTo()<CR>
map <silent> <leader>ad :call <SID>ASPLoadDB()<CR>
imap <silent> <leader>ad <ESC>:call <SID>ASPLoadDB()<CR>


function! s:MVCMode()
    if search('System.Web.Mvc','n') != 0
        return 1
    else
        return 0
    endif
endf

function! s:ASPLoadDB()
    if !exists('g:loaded_dbext')
        echoh ErrorMsg | echo 'Could not find DBExt plugin' | echoh None
        return
    endif

    "find web.config
    let currSearchPath = expand('%:p:h').'\**'
    let fileToFind = findfile('web.config',currSearchPath)
    echo 'found '.fileToFind
    if filereadable(fileToFind)
        for line in readfile(fileToFind)
            "find connstring
            if line =~ '\<connectionString' 
                let dbExtResult = 'type=SQLSRV'
                let name = matchstr(line, 'name="\w*"') 
                let nameValue = matchstr(name, '"\w*"')
                let connstring = matchstr(line, 'connectionString=".*"') 
                let connstringValue = matchstr(connstring,'".*"') 
                for connValue in split(substitute(connstringValue,'"','',''),';')
                    let connList = split(connValue,'=')
                    if connList[0] =~ '[Dd]atabase\|[Ii]nitial [Cc]atalog'
                        let dbExtResult .= ':dbname='.connList[1]
                    elseif connList[0] =~ '[Ss]erver\|[Dd]ata [Ss]ource'
                        let dbExtResult .= ':srvname='.connList[1]
                    elseif connList[0] =~ '[Ii]ntegrated [Ss]ecurity\|Trusted_Connection'
                        if connList[1] =~ 'SSPI\|True'
                            let dbExtResult .= ':integratedlogin=1'
                        endif
                    elseif connList[0] =~ 'UID\|User I[Dd]\|uid'
                        let dbExtResult .= ':user='.connList[1]
                    elseif connList[0] =~ '[Pp]assword\|PWD\|pwd'
                        let dbExtResult .= ':passwd='.connList[1]
                    endif
                endfor
                if dbExtResult != 'type=SQLSRV'
                    echo 'let g:dbext_default_profile_'.substitute(nameValue,'"','','g').'='''.dbExtResult.''''
                    exe 'let g:dbext_default_profile_'.substitute(nameValue,'"','','g').'='''.dbExtResult.''''
                endif
            endif
        endfor
    else
        echoh ErrorMsg | echo 'Could not find web.config' | echoh None
    endif
endf

function! s:ASPAltFile(newWin)
    if s:MVCMode()
        "MVC Mode assumes they followed MVC naming conventions for files and
        "folders
        if expand('%:e') == 'aspx'
            "if in view, look at folder name and find controller of same name
            let foldername = expand('%:h:t')
            let currSearchPath = expand('%:p:h:h:h').'\Controllers\**'
            let fileToFind = findfile(foldername.'Controller.cs',currSearchPath)
            if filereadable(fileToFind)
                if a:newWin == 1
                    exe 'sp '
                endif
                exe 'e '.fileToFind
            else
                echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
            endif
        else
            "if in controller, get function name and look for aspx of same name in view folder
            "get current function name (eg - About)
            let functionLine =  search('public','bcW')
            if functionLine != 0
                normal f(b
                let currFunc = expand('<cword>')
                let currFileName = substitute(expand('%:p:t:r'),'Controller','','')

                "Find file in Views folder then "Home" folder then "About".aspx
                let currSearchPath = expand('%:p:h:h').'\Views\'
                let fileToFind = currSearchPath.currFileName.'\'.currFunc.'.aspx'
                if filereadable(fileToFind)
                     if a:newWin == 1
                         exe 'sp '
                     endif
                    exe 'e '.fileToFind
                else
                    echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
                endif
            else
                echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
            endif
        endif
    else
        let currExt = expand('%:e') 
        if currExt == 'aspx' || currExt == 'ascx' 
            let path = expand('%:p').'.'
            let extensions = ['cs','vb']
            if !s:ReadableWithExt(path, extensions, a:newWin)
                  echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
            endif
        elseif currExt == 'cs' || currExt == 'vb'
            let path = expand('%:p:r')
            let extensions = ['aspx','ascx']
            if !s:ReadableWithoutExt(path, extensions, a:newWin)
                  echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
            endif
        else
            echoh ErrorMsg | echo 'Alternate file not found.' | echoh None
        endif
    endif
endf

function! s:ReadableWithExt(path, extensions, newWin)
	for ext in a:extensions
		if filereadable(a:path.ext)
             if a:newWin == 1
                 exe 'sp '
             endif
             exe 'e '.a:path.ext
			return 1
		endif
	endfor
	return 0
endf

function! s:ReadableWithoutExt(path, extensions, newWin)
	for ext in a:extensions
		if filereadable(a:path)
             if a:newWin == 1
                 exe 'sp '
             endif
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

    "Parse out sln to determine version
    if filereadable(dotnet_sln)
        let slnVersion = '0'
        for line in readfile(dotnet_sln)
            if line =~ '11.00'
                let slnVersion = '11.00'
            endif
        endfor

        if slnVersion == '11.00'
            "TO DO - Make these more generic
            let msbuild = 'C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\MSBuild.exe'
        else
            let msbuild = 'C:\\WINDOWS\\Microsoft.NET\\Framework\\v3.5\MSBuild.exe'
        endif
    endif
    
    au QuickfixCmdPost make call QfMakeConv()
    let foundsln = 0
    let foundmsbuild = 0
    "for msbuild in msbuildpaths
        if filereadable(msbuild)
            let foundmsbuild = 1
            if filereadable(dotnet_sln) 
                let foundsln = 1
                " TO DO :pass in sln or proj path to msbuild rather than changing current dir
                exe 'cd '. fnamemodify(dotnet_sln, ':p:h') 
                exe 'set makeprg='.msbuild.'\ /nologo\ /v:q\ '
                mak
                return 1
            endif
        endif
    "endfor
    "add some messaging if things go bad
    if foundsln == 0
        echoh ErrorMsg | echo 'Could not find solution file.' | echoh None
    endif
    if foundmsbuild == 0
        echoh ErrorMsg | echo 'Could not find msbuild.' | echoh None
    endif
endf

"setup integrated help
function! s:ASPHelp()
  let wordUnderCursor = expand("<cword>")
  let url = "http://social.msdn.microsoft.com/Search/en-US/?Query=" . wordUnderCursor
  let cmd = ":silent ! start " . url
  execute cmd
endfunction


fun! s:QfMakeConv()
    let finalList = []
    let qflist = getqflist()
    for i in qflist
        if match(i.text, "[Ee]rror") > 0 
         call add(finalList,i)
        endif
    endfor
    if len(finalList) == 0
        let i = qflist[0] 
        let i.text = "Build Succeeded!"
        call add(finalList,i)
    endif
    call setqflist(finalList)
endf

"start local web server and browser
function! s:ASPRun()
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
    "Parse out sln to determine version
    if filereadable(dotnet_sln)
        let slnVersion = '0'
        for line in readfile(dotnet_sln)
            if line =~ '11.00'
                let slnVersion = '11.00'
            endif
        endfor
        echo 'version '.slnVersion

        if slnVersion == '11.00'
            "TO DO - Make these more generic
            let serverpaths = ['C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer40.exe', 
                        \        'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer40.exe']
        else
            let serverpaths = [ 'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe',
                        \        'C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe']
        endif
    endif
  "let serverpaths = ['C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer40.exe', 
              "\        'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\10.0\\WebDev.WebServer40.exe',
              "\        'C:\\Program Files\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe',
              "\        'C:\\Program Files (x86)\\Common Files\\microsoft shared\\DevServer\\9.0\\Webdev.WebServer.exe']
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
  echoh ErrorMsg | echo 'Could not find local webserver at path'.path | echoh None
  return 0
endfunction


