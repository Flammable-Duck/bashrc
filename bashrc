# duck's .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# eval $(cat /home/duck/.profile)
source /home/duck/.profile

# History
export HISTFILESIZE=infinite
export HISTSIZE=1000000
export PROMPT_COMMAND="history -a"
shopt -s histappend

# Plugin Setup
eval "$(zoxide init bash)"
eval "$(starship init bash)"
eval "$(direnv hook bash)"
eval "$(rbenv init - bash)"

### Aliases
alias ls="exa --icons --group-directories-first"
alias la="ls -a"
alias ll="ls -al"
alias tree="ls --tree"
alias cls="clear"
alias clls="clear; ls"
alias less="less -r"
alias feh="feh -B '#191724'"
alias brc="nvim ~/.bashrc && source ~/.bashrc"
alias uztd="unziptodir"
alias txtd="tarxtodir"
alias nightlight="redshift -O 1000K"
alias daylight="redshift -x"
alias adb="echo 'run me as root dumbass';alias adb='adb' #"

### Functions

spt() {
## Start spotify tui with spotifyd
    if [[ -z $(pidof "spotifyd") ]]; then
        echo "spotifyd not running, starting now."
        passwd=$(pass spotify.com/leohagerstrand+spotify@protonmail.com)
        if [[ -z ${passwd} ]]; then
            echo "failed to retrive spotify password."
            return 0
        fi
        spotifyd -b pulseaudio --password=${passwd} && spotify-tui
    else
        spotify-tui
    fi
    return 0
}

vpn() {
## Connect to PIA
    sudo bash -c 'source /home/duck/Desktop/manual-connections/ENV \
        && /home/duck/Desktop/manual-connections/run_setup.sh'
}

ipwtf() {
## Get IP adress
    curl -s https://wtfismyip.com/json | jq
}

xs() {
## xbps-install fuzzy finder
    xpkg -a |
        fzf -m --preview 'xq {1}' \
        --preview-window=right:66%:wrap |
        xargs -ro xi
    }

hs() {
## history fuzzy finder
    cmd=$(history | fzf | cut -c8-)
    echo ${cmd}
    history -s ${cmd}
    eval ${cmd}
}

web_docs() {
## HTML, CSS, JS, and SVG documentation
    fd . ~/Documents/web_docs/ --extension html --extension md\
        | fzf -m \
        | xargs -I {}\
        firefox --profile /home/duck/.mozilla/firefox/1rge8lh6.docs {} &!
    
}

aliases() {
## List aliases
    reset=$(color -c reset -m "")
    dim=$(color -i -c dim -m "")
    f_style=$(color -b -c cyan -m "")
    a_style=$f_style
    m_style="$(color -b -c green -m "")"
    awk '
    /\w\(\) \{/ {
        split($0, a, "#")
        {print "'$f_style' " $1 "'$reset$dim'"a[2]"'$reset'"}
        {getline}
        sub("[#]*[ ]*", "")
        {print " | " $0}
    }
    /^alias / {
        sub("alias ", "")
        gsub("\"", "")
        split($0, a, "=")
        {print "'$a_style' "a[1] "'$reset'" " -> " a[2]}
    }
    /^###/ {
        sub("[#]*[ ]*", "")
        {print "'$m_style'" $0 "'$reset'"}
    }
    ' ~/.bashrc
}

sysbkp() { # $path/to/drive
## Sync $HOME with external drive
    if [[ -e $1 ]]; then
        echo "Syncing ${1} with system"
        rsync -a --delete $HOME ${1}
        echo "Last synced" $(date) > $1/backup_info
        else
            echo "media does not exist"
    fi
}

unziptodir() { # $archive.zip
## extract an archive into a correspondingly named directory
    if [[ "$1" != *.zip ]]; then
        echo "not a zip archive."
        return 1
    fi
    unzip -q "$1" -d "${1%.zip}" \
        && rm "$1"
    # mv "$1" "${1%.zip}"
}

tarxtodir() { # $archive.tar.gz
## extract an archive into a correspondingly named directory
    if [[ "$1" != *.tar.gz ]]; then
        echo "not a tar archive."
        return 1
    fi
    DIR=${1%.tar*}
    mkdir ${DIR}
    tar xf "$1" --directory="${DIR}" \
        && rm "$1"
    # mv "$1" "${DIR}"/
}

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
