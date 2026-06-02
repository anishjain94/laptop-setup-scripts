# Kill process running on a specific port
# Usage: killport <port_number>
# Example: killport 3000
function killport() {
    # Check if port number is provided
    if [[ $# -eq 0 ]]; then
        echo "Error: Please provide a port number"
        echo "Usage: killport <port_number>"
        echo "Example: killport 3000"
        return 1
    fi
    
    local port=$1
    
    # Validate that the input is a number
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number"
        return 1
    fi
    
    # Find the process ID (PID) using the port
    # lsof: "list open files" - shows which processes are using which files/ports
    # -t: returns only the PID (terse output)
    # -i:PORT: filters for internet connections on the specified port
    local pid=$(lsof -t -i:$port)
    
    # Check if any process was found
    if [[ -z "$pid" ]]; then
        echo "No process found running on port $port"
        return 0
    fi
    
    # Display information about the process before killing it
    echo "Found process(es) running on port $port:"
    lsof -i:$port
    echo ""
    
    # Kill the process
    # kill -9: sends SIGKILL signal (forceful termination)
    # You can use just 'kill $pid' for graceful termination (SIGTERM)
    if kill -9 $pid 2>/dev/null; then
        echo "Successfully killed process(es) with PID: $pid"
    else
        # If regular kill fails, try with sudo
        echo "Regular kill failed. Attempting with sudo..."
        if sudo kill -9 $pid; then
            echo "Successfully killed process(es) with PID: $pid using sudo"
        else
            echo "Failed to kill process even with sudo."
            return 1
        fi
    fi
}

# AWS Pipeline Monitor function
# Usage: awsBranch [filter1 filter2 ...]
# If no filters are provided, the default filter "kulu" will be used.
function awsBranch() {
    # Store the current directory
    local current_dir=$(pwd)
    local aws_monitor_dir="/Users/anish/Desktop/work/kulu/AWSPipelineMonitor"
    local script_path="$aws_monitor_dir/pipeline_monitor.py"
    local venv_path="$aws_monitor_dir/venv"
    local venv_activated=0
    
    # Check if the AWS Pipeline Monitor directory exists
    if [[ ! -d "$aws_monitor_dir" ]]; then
        echo "Error: AWS Pipeline Monitor directory not found at $aws_monitor_dir"
        return 1
    fi
    
    # Change to the AWS Pipeline Monitor directory
    cd "$aws_monitor_dir"
    
    # Check if the pipeline_monitor.py script exists
    if [[ ! -f "pipeline_monitor.py" ]]; then
        echo "Error: pipeline_monitor.py script not found in $aws_monitor_dir"
        cd "$current_dir"  # Return to original directory
        return 1
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "$venv_path" ]]; then
        echo "Warning: Virtual environment not found at $venv_path"
        echo "Proceeding with system Python..."
    else
        # Define cleanup function
        function cleanup {
            # Deactivate virtual environment if it was activated
            if [[ $venv_activated -eq 1 ]]; then
                echo "Deactivating virtual environment..."
                deactivate 2>/dev/null
            fi
            
            # Return to original directory
            cd "$current_dir"
        }
        
        # Setup trap to ensure cleanup on exit
        trap cleanup EXIT INT TERM
        
        # Activate virtual environment
        echo "Activating virtual environment..."
        if source "$venv_path/bin/activate" 2>/dev/null; then
            venv_activated=1
            echo "Virtual environment activated successfully."
        else
            echo "Warning: Failed to activate virtual environment. Proceeding with system Python..."
        fi
    fi
    
    # Execute the Python script with any provided filters
    if [[ $# -gt 0 ]]; then
        # If arguments are provided, pass them as filters
        python3 "$script_path" --filters "$@"
    else
        # If no arguments are provided, use default behavior
        python3 "$script_path"
    fi
    
    # Cleanup is handled by the trap, but ensure we return to original directory
    # if trap doesn't fire for some reason
    if [[ $venv_activated -eq 1 ]]; then
        deactivate 2>/dev/null
    fi
    cd "$current_dir"
}

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git kubectl kube-ps1 zsh-autosuggestions zsh-syntax-highlighting )
RPROMPT='$(kube_ps1)'
export PATH="$HOME/.bin:$PATH"
source $ZSH/oh-my-zsh.sh
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


export VAULT_SKIP_VERIFY=true

export PATH=$PATH:$(go env GOPATH)/bin
ghpr() {
    local branch=$(git branch --show-current)
    git push --set-upstream origin "$branch" && gh pr create --web -a @me "$@"
}
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export PATH="/Applications/IntelliJ IDEA CE.app/Contents/MacOS:$PATH"

b64d() {
  echo -n "$1" | base64 --decode
}


redis-stage() {
redis-cli -h master.stage.lkjmtl.euw2.cache.amazonaws.com --user idp -a 'xWMpI$6lRF<O23D&' --tls 
}

eval "$(zoxide init zsh)"

alias intellij='/Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS/idea'

# >>>> Vagrant command completion (start)
fpath=(/opt/vagrant/embedded/gems/gems/vagrant-2.4.7/contrib/zsh $fpath)
compinit
# <<<<  Vagrant command completion (end)
