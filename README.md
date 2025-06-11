# Script-Spliter
Tool addon for Godot 4, this addon allow split the script editor window.

[![Godot Engine 4.3](https://img.shields.io/badge/Godot_Engine-4.x-blue)](https://godotengine.org/) ![ToolHack](https://img.shields.io/badge/Tool-Addon-green) ![Copyrights License](https://img.shields.io/badge/License-MIT-blue)


## Table of contents

- [Preview](#preview-)
- [News](#news-)
- [Features](#features-)
- [Roadmap](#roadmap)
- [How-Work](#how-work)
- [Know Issues](#know-issues-)
- [Special Thanks](#special-thanks-)


# Preview [↑](#table-of-contents)

### V0.2 Video Preview
[![video preview](https://github.com/user-attachments/assets/636cddf4-815e-4bf3-acab-13c26ff21318)](https://youtu.be/ISSu45qzWWw)

### V0.1 Image Preview
![image](https://github.com/user-attachments/assets/a6e1dea8-74cf-4fd9-b0b4-ec7d65ea3995)

# NEWS [↑](#table-of-contents)

### V0.3
<p align="center">
  <img width="128" height="128" src="addons/script_spliter/assets/github_CodeNameTwister.png">
</p>
Introduction to using tabs

* Tabs can be dragged to another window, now you can move one document from a window split to another window split.
* Backward and Forward has an internal function with the plugin. (Thanks to [@adancau](https://github.com/adancau))

>*I had initially planned to create a Notepad++ like functionality as a reference for version 0.3, but it has been decided to maintain the functionality and backward compatibility to avoid confusion for those using the plugin since version 0.1.*

### Drag and Drop
You can use tabs to drag and drop into another split window to switch between editors or you can drag directly from the script list and drop into the split window.

### Modify Backward and Forward buttons
You can modify the buttons by input resources in "script_spliter/io" folder,
seen in [Backward/Forward Request](https://github.com/CodeNameTwister/Script-Spliter/issues/9#issuecomment-2917555511)

### Using Backward/Forward
It is per-window history, this means that if you've navigated through three different scripts within the window, moving back will only move between those three. The same happens when moving forward, and it's not affected by any other movements you've made in another window.
>[!TIP]
>In editor settings you have the checkbox: "using_as_next_and_back_tab" if you want use Backward/Forward move like Back/Next Tab.
#

### V0.2
<p align="center">
  <img width="128" height="128" src="https://github.com/CodeNameTwister/Misc/blob/main/media/ico_gdsp2.png?raw=true">
</p>
The internal workflow has been modified, but the functionality of its predecessor version has been maintained.

This has been done to maintain compatibility when using shorteners like Ctrl + [1, 2, 3, 4] to change the split style, this might be broken in version 0.3, see the roadmap for details.

### Differences with version 0.1
* It more closely resembles the default editor window.
* Reduces window switching time.
* Allows you to zoom in on all windows.
* You may have a separate script documentation help window.
* Some visual aspects and configurable parameters in Editor Settings.
* More Features and Split Options.

>[!NOTE]
>This plugin uses another built-in plugin created by me called [Multi Split Container](https://github.com/CodeNameTwister/Multi-Split-Container)


# Features [↑](#table-of-contents)
* Split Window of Document Files Like Script/Document Helper Window.
* Split Two Window Horizontal/Vertical.
* Split Three Window Horizontal/Vertical.
* Split Four Window Squared.
* Split Custom Window defined by you. *(using RMB context menu or Tool Menu)*
* Plugins Setting in Editor Settings. *(In the section Plugin, you can see with advance option enabled!)*
* Pop Script: Make Floating Script in Separate Window using RMB context menu.
* Refresh Warnings changes in all opened windows when project is saved *(Errors/Warning Script)*
* Reopen recently closed/changed scripts when adding a split. (Suggestion: [#5](https://github.com/CodeNameTwister/Script-Spliter/issues/5))
* Swap between windows by double-clicking the draggable button. (Suggestion: [#8](https://github.com/CodeNameTwister/Script-Spliter/issues/8]))
* Back and Forward between script opened by the window splited. (Suggestion: [#9](https://github.com/CodeNameTwister/Script-Spliter/issues/9]))
* Drag and Drop tabs between windows.
* Tabs close options using (RMB) context menu.
  
>[!WARNING]
>Experimental Refresh Warnings *(This option can be disabled on Editor Settings)*

>[!NOTE]
>In [DocEditorSettings.md](DocEditorSettings.md) you can see the description of the settings.



# ROADMAP
* Version >= 0.2.3: ~Flying scripts; Allow split in separate windows.~
* Version >= 0.3:
  * ~Change logo/colors: Currently the pet I use on github is placed and it is planned to change it to one more suitable for the plugin.~
  * ~Using tabs for drag and drop between windows.~ *~(WARNING! : Some features offered in previous versions may change)~*
* Version >= 0.4: Revisit Pop Scripts Issues.

# How Work
  
>[!TIP]
> Now you can add or remove split with using context menu, the popup menu appear using the RMB (Right mouse button) in the editor.
>
> * Use Add/Remove split if you want increase or decrease the auto split window function.

>[!NOTE]
> Keep in mind, the style when appear new window (As Column or Row) depend of you configuration split style!
>
> *This may change in future releases.*

### Enable by shortcut [↑](#table-of-contents)
* Press shortcut (**Ctrl + 1**) for set one window.
* Press shortcut (**Ctrl + 2**) for set one split of two windows: Horizontal.
* Press shortcut (**Ctrl + 3**) for set one split of two windows: Vertical.
* Press shortcut (**Ctrl + 4**) for set two split of three windows: Horizontal.
* Press shortcut (**Ctrl + 5**) for set two split of three windows: Vertical.
* Press shortcut (**Ctrl + 6**) for set three split of four windows: Squared split.

### Enable by Tool Menu [↑](#table-of-contents)
For enable the Script spliter menu go to **Project > Tools > Script Spliter**.

![image](images/img0.png)

You can select split type and disabled, see the image.

![image](images/img1.png)

Once activated, you'll see a draggable line like the one in the image, indicating that the plugin is active.

>[!IMPORTANT]
>This section will automatically expand when you open **two scripts**.

The position of the line will vary depending on the selection of horizontal or vertical.

![image](images/img2.png)

# Know Issues [↑](#table-of-contents)
### Version 0.2.3
The **PopScripts** (Floating Scripts) 
It still has some issues related to the editor focus, which means that if you switch scenes, some features like the search engine within the PopScript may be affected and become unresponsive.

# Special Thanks 📜 
This section lists users who have contributed to improving the quality of this project.

[@adancau](https://github.com/adancau)

#
Copyrights (c) CodeNameTwister. See [LICENSE](LICENSE) for details.

[godot engine]: https://godotengine.org/
