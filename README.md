# nvm-session
Wrapper for NVM for Windows that allows multiple GitBash windows or tabs to use different node versions.

This bash function allows individual GitBash terminal windows to use their own node versions. This key feature of the real nvm (for Mac/Linux/WSL) is missing in NVM for Windows.

## Usage
In your .bashrc file, add
```
. <path-to-nvm-session-repo>/nvm-session.sh
```
Then, in a GitBash terminal window, do
```
nvm-session use <installed-node-version>  # e.g., nvm-session use 12.16.2
nvm-session <other-nvm-action>            # Calls nvm to handle all other requests
```

## Requires
* NVM for Windows (See https://github.com/coreybutler/nvm-windows)
* Git for Windows a.k.a. GitBash (https://gitforwindows.org/)

## Known Limitations
* When you enter a GitBash terminal session, the nvm's global node version will be available. No default is set.
* cmd.exe windows not supported. Could be supported via batch script/powershell, I don't need it (yet).

## How It Works
NVM for Windows magic is that it installs each of the requested node versions into 
`$APPDATA/Roaming/nvm/v$VERSION`

When you do a `nvm use 12.16.2` or somthing, NVM for Windows creates a symlink at C:\Program Files\nodejs to the selected version. This creates a globally accessible node version (from cmd.exe or gitbash).

This script leverages the fact that every versioned node directory is a clean, standalone, and more importantly, usable version of node.

By prepended the path to the requested version of node to terminal's PATH variable, that terminal session becomes independent of the globally set nvm/node version, allowing us to have different versions of node in each terminal session.

The `nvm on` and `nvm off` global actions do not affect this, it'll work with it on or off.
