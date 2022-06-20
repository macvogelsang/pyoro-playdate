
# Public Pyoro Port for Playdate

A Bird and Beans remake for Playdate. This source code is the final 1.0.3 version of the game before it was removed from itch.io. The code has had all the copyrighted music stripped, but may be helpful for anyone for learning the Playdate SDK. This was my first Playdate project and many aspects of the code are messy. 

# Latest release
The .pdx file for the v1.0.3 version can be found [here](https://github.com/macvogelsang/pyoro/releases/tag/v1.0.3) in the git releases sidebar.

# Changelog

### v1.0.3
- Added settings option to turn of music or sound effects
- Added falling leave effects to game 2. This is a feature from the original game that I held off on implementing because I thought the extra sprites would have a performance impact, and indeed they did. So there is now an extra setting in the menu: leaf effects 'off', 'on', or 'auto'. 'Auto' keeps the effects on until there are too many sprites on screen where framerate starts to significantly drop and then turns off the effects. If anyone wants to help me improve performance on this front, feel free to reach out.
- Added a more interesting loading screen transition 
- Added hills to the launcher card
- Fixed a bug where the flashing beans would spawn too early if the screen was just cleared
- Fixed yet another main menu bug
- Fixed two almost-imperceptable graphical issues  
- Fixed some bugs you'll never know about since they were introduced in patch 1.0.3 

### v1.0.2

- Increased ground friction to more closely match the original
- Player velocity now increases along with bean speed
- Adjusted menu sound effects
- Fixed another main menu button bug

### v1.0.1

- Tweaked launcher animation
- Fixed main menu crash
- Fixed tongue persisting after death
- Fixed the tongue not speeding up when bean speed increases
- Tweaked scoring thresholds a tiny bit