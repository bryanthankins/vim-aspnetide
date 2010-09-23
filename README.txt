Turns VIM into an asp.net IDE! 

Features 
------------- 
* OnlineDoc - F1: Jump to online help based on selected word. 
* BuildSolution - <leader>B: Find a solution file for the project and build. Errors shown in quickfix. 
* AlternateFile - <leader>A: Navigate to alternate files (ASPX <-> code-behind). 
* ShowAppInBrowser - F5: Run app in local webserver and navigate to selected page. 
* GoToFile - <leader>G: Look for class file based on current word.

Notes 
-------- 
* For those new to vim, <leader> is typically a backslash on windows boxes. 
* Alternate file navigation is ASP.NET webforms specific. No ASP.NET MVC support yet. 
* You may need to have VS.NET installed for ShowAppInBrowser to work. Not sure if the local web server gets installed with just the framework 
* The  BuildSolution and ShowAppInBrowser features only work on windows. With a few tweaks this could work nicely for mono on linux though...
 
Usage
------
Copy plugin file to vimfiles/plugin/aspnetide.vim.

