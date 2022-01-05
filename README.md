# Melkor's Oubliette 

An old school dungeon crawler in the style of Dungeon Master or Eye Of The Beholder, also known as a ["Blobber" style of RPG](https://www.giantbomb.com/blobber/3015-8752/#:~:text=Blobber%20is%20a%20slang%20term,entity%20in%20the%20game%20world.&text=Functionally%2C%20this%20means%20that%20the,acts%20as%20a%20single%20unit.)

This is currently EXTREMELY work in progress, don't even think of it as an alpha. It is written in [Godot](https://godotengine.org/)

Some current features:
- Customisable maps and levels
- Interactive switches and buttons, with a flexible action system
- Doors (wood and portcullis)
- Dynamic lighting, requiring the player to pick up and find torches which fade and burn out over time.
- Pits and flooded levels
- Chain levels together with exits
- Wall decorations, including readable signs and torches
- Items, which can be picked up and moved and held in inventory

## Screens

![Screenshot 2022-01-05 121847](https://user-images.githubusercontent.com/14982936/148216736-7dbdaa47-ca78-4a77-a10f-5443fd85c0dc.png)
![Screenshot 2022-01-05 121920](https://user-images.githubusercontent.com/14982936/148216741-1aa24865-f20e-481f-8a1c-cb38219c9a40.png)
![Screenshot 2022-01-05 122016](https://user-images.githubusercontent.com/14982936/148216743-a3978f1a-e350-470a-8e59-fbd7f9abc783.png)

## Videos

Short demo video on YouTube
[https://www.youtube.com/watch?v=e5uBlCVDgPY](https://www.youtube.com/watch?v=e5uBlCVDgPY)


## Reference

### Level File format

Levels are defined in YAML. Custom levels should go into `%APPDATA%\Godot\Melkor's Oubliette\app_userdata\levels\Some Folder\` where `Some Folder` is a name of your choice and will be seen when picking a level on the title screen. There must be a YAML file named `start.yaml` inside that folder. Other levels can be named as you wish and accessed via level exits

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
