function nvm-session-usage() {
    [ $# -gt 0 ] && printf "%s\n" "$@" 
    echo "Usage: "
    echo "  nvm-session use <version>    : Switch to the specified version"
    echo "  nvm-session use              : Show installed versions (same as list)"
    echo "  nvm-session list|ls          : Shows installed versions and which is active"
    echo "  nvm-session <other-nvm-cmd>  : Calls nvm to run command"
    echo
}

function nvm-session-list() {
    local cleanNvmList nodeVersion
    
    if [ $# -ne 0 ]; then
        nvm-session-passthru list "$@"
        return $?
    fi

    # Outputs 'nvm list' but without any active versions marked
    #   get installed versions | leave only version | strip blank lines
    cleanNvmList=$(nvm ls 2> /dev/null | sed "s/^[^0-9]* \([0-9][0-9\.]*\).*/\\1/" | sed '/^\s*$/d' 2> /dev/null)
    nodeVersion=$(nvm-session-nodever)
    echo "Installed versions:"
    echo $cleanNvmList | tr " " "\n" | sed "s/^$nodeVersion/* $nodeVersion (active)/" | sed "s/^\([^\\*]\)/  \\1/"
}

function nvm-session-nodever() {
    # Node on windows doesn't use tty so you can't parse stdout - Argg. Do some which+ls magic
    local nodePath nodeVersionDir nodeVersion nodejsInDir
    nodePath=$(which node)
    [ $? -ne 0 ] && return 1

    if [[ "$nodePath" == */nodejs/node ]]; then
        # Using global version, follow the symlink from Program Files
        nodejsInDir=$(dirname "$nodePath")     # Up to nodejs dir
        nodejsInDir=$(dirname "$nodejsInDir")  # Up to parent dir
        nodePath=$(ls -l "$nodejsInDir" | grep nodejs | awk -F"->" '{print $2}')/node # Get real node dir
    fi

    nodeVersionDir=$(dirname "$nodePath")                     # Path to node version dir
    nodeVersion=$(basename "$nodeVersionDir" | sed "s/^v//") # Just version
    echo $nodeVersion
}

function nvm-session-passthru() {
    nvm "$@"
}

function nvm-session-use() {
    local useVersion cleanPath nvmHome
    if [ $# -ne 1 ]; then
        nvm-session-list
        return 1
    fi
    useVersion=$1
    nvm-session-list | grep -q $useVersion
    if [ $? -ne 0 ]; then
        echo "Error: node version '$useVersion' not installed."
        nvm-session-list
        echo "Or try 'nvm-session list available' and 'nvm-session install <version>'' to add more."
        return 1
    fi

    # Update path with requested version
    cleanPath=$(echo $PATH | tr ':' '\n' | grep -v /nvm/v | tr '\n' ':')
    nvmHome=$(dirname $(which nvm)) # NVM_HOME is Windows style, need GitBash style path
    export PATH="$nvmHome/v$useVersion:$PATH"
    echo "nvm-session: now using v$useVersion"
    return 0
}

function nvm-session() {
    which nvm 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: NVM for Windows not found. Please ensure it is in your path."
        return 1
    fi

    case "$1" in
        help|-h*|'')
            nvm-session-usage
            return 1
            ;;
        use) 
            shift
            nvm-session-use "$@"
            return $?
            ;;
        list|ls)
            shift
            nvm-session-list "$@"
            return $?
            ;;
        *)
            nvm-session-passthru "$@"
            return $?
            ;;
    esac
}
