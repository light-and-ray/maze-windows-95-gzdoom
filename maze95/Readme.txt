Maze 95 UZDX - Ultimate ZDoom Experience
========================================

This is an almost one to one recreation of the 3d maze screensaver from Windows 95. If you always wanted
to play this "game" - now you can do it in the most advanced and portable Doom source ports!

Requirements: GZDoom/LZDoom/UZDoom v4.11+; OpenGL or Vulkan rendering backend (read more below)
It does not require Doom or Doom 2 wad. It is technically a standalone game in ipk3 format. But if
you want, you can call it a total conversion

All the features of the original are here:
- Random maze generation
- OpenGL logo sprites and walls
- Rat with maze walking AI
- Platonic solids that rotate you upside down
- Auto maze walker AI as a titlemap
- Level stretching at the start and end of the level
- Obscured walls and things behind the visible walls while stretching

Ultimate ZDoom Experience opens a lot of possibilities for you!:
- Play in the Maze by yourself!
- 4 difficulty levels:
    1. Relaxed - Walls are very short, No upside down
    2. Easy - No upside down
    3. Normal - Nothing changed
    4. Hard - More tight maze generation; sometimes the rule "turn always left" / "turn always right" is broken
- Toggle freelook on "F" key
- You will probably want to use noclip. Use command "bind v noclip2" and toggle noclip on "V" key
- To open the auto walking screensaver map separately - use "map titlemap" command
- You can use universal GZDoom/UZdoom mods. For example, I recommend
    https://www.moddb.com/mods/gzdoom-demake-shaders/downloads
- If you want to make a mod - you can do it

More about the rendering API requirement: you must have set rendering backend to OpenGL or Vulkan.
OpenGL ES, Softpoly and Software rendering modes don't support custom material shaders and
post processing shaders that are used a lot in this project. Otherwise you will see warning sprites
on levels. If you can't change rendering API in the game - it means your launcher forces a different
API and you need to change it in the launcher. For example in Delta Touch you need to open the source
port options (gear icon), change rendering backend to GLES 3.2 and unset "Disable user shaders",
"Disable post processing shaders" switches

The amazing Windows 95 ambient music is taken from https://youtu.be/DrmpZtxr0kY. Leave it a like
