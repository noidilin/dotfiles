# PC Setup

## Install Win11

Use **_Rufus_** to make iso USB drive to avoid microsoft online account validation which could ruin your user name (user folder name). Changing user name afterward is hard and has the possibility to break some essential features.

### Use Rufus to create bootable drive

1. download and launch rufus
2. select preferred flash drive to create bootable USB iso
3. select win 11 iso file downloaded from microsoft website
4. click start
5. check 'remove requirement for an online microsoft account'
6. check 'create a local account with username'
   - specify a name for the account
   - bypass other restriction if you want
7. click ok

### Driver

- motherboard (X570 Meg Ace):
  - it will automatically prompt to install necessary motherboard driver.
  - remember to uncheck some unnecessary applications in default selection.
- cpu: amd razen master (optional)
- gpu: studio version
- hard drive: acronis true image WD (optional)

---

## Manually setup

- Correcting HDMI and DP Color on Nvidia GPUs
- install cursor icon in the `.config/cursor/`

### `~/.local/etc/`

- `resolve`: manually link 'Resolve Project' as database and import preference
- `firefox`: global speed, sidebery, tampermonkey, tweaks for yt, yt subscription manager
- `stylus`: color-fatigue.json
- `shareX`: theme, config (manually assign config path in the app)
- `pureref`: theme (manually import theme to app)
- `keyboard`: bioi g60, cidoo abm066, dz60, lot60
- `blender`: config, preset theme

### Resolve plugin

- mInstaller
- Dehancer Pro
- VST3:
  - Wave central: CLA-76, Playlist Rider, NS1, WLM Meter, WLM Plus, MV2, Voice centric
  - iZotope: Vocal Doubler, Ozone Imager 2, Vinyl
  - T-De-Esser
  - Cymatics origin

---

## D drive

Files in D drive is backed up into two places:

|          | D drive           | oneDrive                  |
| -------- | ----------------- | ------------------------- |
| project  | current project   | temp synced files         |
| area     | downloads, render | obsidian asset archive    |
| resource | tex, FX, blender  | course, preset, reference |
| archive  | cache             | legecy files              |
