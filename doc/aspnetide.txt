*aspnetide.txt*   A Plugin that turns vim into an asp.net IDE! 
                                                
Author: Bryant Hankins <bryanthankins@gmail.com>*aspnetide-author*

INTRODUCTION                                    *aspnetide-intro*

This plugin allows you to easily edit ASP.NET applications with vim. It attempts to give you some of the niceties you may be used to from a full IDE without getting in your way like a full IDE.

aspnetide defines the following commands:

|:ASPHelp|
|:ASPBuild|
|:ASPAltFile|
|:ASPRun|
|:ASPGoTo|
|:ASPDatabase|
 
:ASPHelp                                         *:ASPHelp*
   Jump to online help based on selected word: F1 or <leader>ah

:ASPBuild                                       *:ASPBuild*
   Find a solution file for the project and build. Errors shown in quickfix. Function mapped to <leader>ab

:ASPAltFile                                     *:ASPAltFile*
   Navigate to alternate files (ASPX <-> code-behind). It will detect whether it's running in a webforms or MVC app. In webforms mode, it will jump between the view and code-behind files. In MVC mode it will jump between Controller and View template. Function mapped to <leader>af or <leader>aw to open in a new window.

:ASPRun                                         *:ASPRun*
   Run app in local webserver and navigate to selected page. Function mapped
   to F5 or <leader>ar

:ASPGoTo                                        *:ASPGoTo*
   Takes you to the class file based on the current word. So if you are on "Utility" it will look through the directory tree for the utility class file. Function mapped to <leader>ag

:ASPDatabase                                    *:ASPDatabase*
   Requires the vim DBext plugin. Parses the web.config and loads all connection strings into preconfigured connections accessible from SQL Buffer Prompt (<leader>sbp) and easy querying from DBExt. Function mapped to <leader>ad

The latest stable version can be found at:
    http://www.vim.org/scripts/script.php?script_id=3243
Latest code can be found at:
    http://github.com/bryanthankins/vim-aspnetide
My homepage is:
    http://www.bryanthankins.com/techblog

Feedback is welcome as are bug reports and patches. 


						*aspnetide-license*
This plugin is distributable under the same terms as Vim itself.  See
|license|.  No warranties, expressed or implied.

 vim:tw=78:ts=8:ft=help:norl:
