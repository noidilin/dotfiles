# Blender

binary: batch render creator, UV pack master core, zen UV core

| type  | path                        |
| ----- | --------------------------- |
| addon | `D:\resource\blender\addon` |
| asset | `D:\resourcy\blender\`      |
| tex   | `D:\resource\tex\`          |

ref: [Blender’s Directory Layout - Blender 4.3 Manual](https://docs.blender.org/manual/en/latest/advanced/blender_directory_layout.html#path-layout)

---

## User directories

User directories store preferences, startup file, installed extensions, presets and more.

Here is the default directories:

- linux: `$XDG_CONFIG_HOME/blender/4.3/`
- macOS: `/Users/$USER/Library/Application Support/Blender/4.3/`
- windows: `%USERPROFILE%\AppData\Roaming\Blender Foundation\Blender\4.3\`

| name                    | description                                                      |
| ----------------------- | ---------------------------------------------------------------- |
| BLENDER_USER_RESOURCES  | Replace default dir of all user. override other `BLENDER_USER_*` |
| BLENDER_USER_CONFIG     | Directory for user configuration files.                          |
| BLENDER_USER_SCRIPTS    | Directory for user scripts.                                      |
| BLENDER_USER_EXTENSIONS | Directory for user extensions.                                   |
| BLENDER_USER_DATAFILES  | Directory for user data files (icons, translations, ..).         |

---

## System directories

System directories store files that come bundled with Blender, and are required for it to function, including scripts, presets, essential assets and more.

Here is the default directories:

- linux: `/usr/share/blender/4.3/`
- macOS: `./Blender.app/Contents/Resources/4.3/`
- windows: `%ProgramFiles%\WindowsApps\BlenderFoundation.Blender<HASH>\Blender\4.3\`

| name                      | description                                              |
| ------------------------- | -------------------------------------------------------- |
| BLENDER_SYSTEM_RESOURCES  | Replace default directory of all bundled resource files. |
| BLENDER_SYSTEM_SCRIPTS    | Directory to add more bundled scripts                    |
| BLENDER_SYSTEM_EXTENSIONS | Directory for system extensions repository.              |
| BLENDER_SYSTEM_DATAFILES  | Directory to replace bundled datafiles.                  |
| BLENDER_SYSTEM_PYTHON     | Directory to replace bundled Python libraries.           |

- blender config: `~\AppData\Roaming\Blender Foundation\Blender\`
- blender preset: `~\blender\`

---

## Other Environment variable

| name   | description                                                                |
| ------ | -------------------------------------------------------------------------- |
| OCIO   | Path to override the OpenColorIO configuration file.                       |
| TEMP   | Store temporary files here (MS-Windows).                                   |
| TMPDIR | Store temporary files here (UNIX Systems). Must reference an existing dir. |
