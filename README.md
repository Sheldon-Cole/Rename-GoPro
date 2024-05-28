# Rename-GoPro

This PowerShell script will rename GoPro Hero files from the standard `GX010001.MP4` to `GoPro-001-010.MP4` so that can be properly sorted in order, in the OS of the users choice.

 $\color{orange}{\textsf{This is currently incorrect as the actual naming convention is GX-01-0001.MP4.}}$
$\color{orange}{\textsf{ This will be fixed in a future update. So long as the file number does not exceed 4 digits, this is safe to use.}}$

## GoPro Naming

- `GX`: Video file/encoding designation
- `010`: Chapter number
- `001`: File number

So, when recording a continuous video, the filenames would be:

1. `GX010001.MP4`
2. `GX020001.MP4`
3. `GX030001.MP4`
4. etc...

When recording the next video, the filenames would:

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

1. `GoPro-001-010.MP4`
2. `GoPro-001-020.MP4`
3. `GoPro-001-030.MP4`
4. `GoPro-002-010.MP4`
5. `GoPro-002-020.MP4`
6. `GoPro-002-030.MP4`
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
  