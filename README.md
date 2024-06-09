# Rename-GoPro

This PowerShell script will rename GoPro Hero files from the standard `GX010001.MP4` to `GoPro-0001-01.MP4` so that the videos can be properly sorted, in order, in the OS of the users choice.
Any LVM and THM files are moved to a separate folder. Currently there is no option to do anything with them, but that will come at a later iteration. 

## GoPro Naming

- `GX`: Video file/encoding designation
- `010`: Chapter number
- `001`: File number

When recording a continuous video, the filenames would be:

1. `GX010001.MP4`
2. `GX020001.MP4`
3. `GX030001.MP4`
4. etc...

Then recording the next video, the filenames would:

1. `GX010002.MP4`
2. `GX020002.MP4`
3. `GX030002.MP4`
4. etc...

When these files get sorted by filename, they would appear like:

1. `GX010001.MP4`
2. `GX010002.MP4`
3. `GX020001.MP4`
4. `GX020002.MP4`
5. `GX030001.MP4`
6. `GX030002.MP4`
7. etc...

Once the script is ran, the files will be renamed and sortable by their filename *THEN* chapter.

1. `GoPro-0001-01.MP4`
2. `GoPro-0001-02.MP4`
3. `GoPro-0001-03.MP4`
4. `GoPro-0002-01.MP4`
5. `GoPro-0002-02.MP4`
6. `GoPro-0002-03.MP4`
7. etc...

***For more information, see: [GoPro Naming Convention](https://community.gopro.com/s/article/GoPro-Camera-File-Naming-Convention?language=en_US)***

## Usage

```PowerShell
Rename-GoProFiles -Path "C:\GoProFiles" -Recurse -ShowMe
```

Retrieves GoPro files from the "C:\\GoProFiles" directory and its subfolders, displays file information, and does not perform any file operations.

```PowerShell
Rename-GoProFiles -Path "C:\GoProFiles" -DestinationPath "D:\RenamedGoProFiles"
```

Retrieves GoPro files from the "C:\\GoProFiles" directory and renames them according to the specified naming convention. The renamed files are moved to the "D:\\RenamedGoProFiles" directory.

Using the `-Copy` switch will make a copy of the files, rename them, and put them in the destination folder.
Using the `-Move` switch will move the original files into the destination folder after renaming.

---
---

### Future addons

- No video group folders \[switch\]
- Duplication warnings/handling
- Delete LVM and THM files \[switch\]
  
