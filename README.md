# Dungeon Trek

An old school dungeon crawler in the style of Dungeon Master or Eye Of The Beholder

This is currently EXTREMELY work in progress, don't even think of it as an alpha

## Video

Longer video in YouTube
[https://www.youtube.com/watch?v=e5uBlCVDgPY](https://www.youtube.com/watch?v=e5uBlCVDgPY)

https://user-images.githubusercontent.com/14982936/147598408-909b5f0e-aa0d-492a-b8ab-5c91568b3099.mp4

## Screens

VERY EARLY SCREENS

![image](https://user-images.githubusercontent.com/14982936/147598096-e492f668-24d8-4b44-9125-ef043e396326.png)

![image](https://user-images.githubusercontent.com/14982936/147598144-d50362ab-1faf-4f31-ab70-681314e3821d.png)

## Reference

### Cheats

To enable various cheats for debugging and level creation, create a `cheats.json` file in `%APPDATA%\Godot\app_userdata\Melkor's Oubliette\`

Contents:
- `jump_level` - Skip the title screen and start immediately on this level.
- `start_pos` - Teleport the player to this cell when starting, provide a two valued array of x & y coords.
- `noclip` - Set this boolean to true to allow you to walk through walls and doors
- `light` - Set this boolean to true to have infinite light without needing a torch

Example:

```json
{
  "jump_level": "res://levels/Melkor's Oubliette/start.yaml",
  "start_pos": [2, 5],
  "noclip": true,
  "light": true
}
