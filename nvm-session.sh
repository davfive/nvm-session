function nvm-session() {
    usage="Usage: nvm-session use <installed-node-verison>  # e.g., nvm-session use 12.16.2"

    nvm=$(which nvm 2> /dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: nvm for Windows not found. Please ensure it is in your path."
        return 1
    fi

    # Pass through everything exept if user asks to switch node versions to use
    if [ "$1" != "use" ]; then
        nvm "$@"
        return $?
    fi

    # Usage check
    if [ $# -ne 2 ]; then
        echo $usage
        return 1
    fi

    # Check requested version is installed
    useVersion=$2
    nvm list 2> /dev/null | grep -q $useVersion
    if [ $? -ne 0 ]; then
        echo "Error: node version '$useVersion' not installed."
        echo "Available versions:"
        nvm list
        echo "Or try 'nvm list available' and nvm install <version> to add more."
        return 1
    fi

    # Update path with requested version
    cleanPath=$(echo $PATH | tr ':' '\n' | grep -v /nvm/v | tr '\n' ':')
    nvmHome=$(dirname $(which nvm)) # NVM_HOME is Windows style, need GitBash style path
    export PATH="$nvmHome/v$useVersion:$PATH"
    echo "nvm-session: now using v$useVersion"
    return 0
}
