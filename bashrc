# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval $(cat /home/duck/.profile)

# History
# =======
export HISTFILESIZE=50000
export HISTSIZE=20000
shopt -s histappend

# Plugin Setup
# ============

eval "$(zoxide init bash)"
eval "$(starship init bash)"
eval "$(direnv hook bash)"
eval "$(rbenv init - bash)"

# Aliases
# =======

alias ls='exa --icons --group-directories-first'
alias la='ls -a'
alias ll='ls -al'
alias tree='ls --tree'
alias cls='clear'
alias clls='clear; ls'
alias zj='zellij'
alias feh='feh -B "#191724"'
alias nightlight='redshift -O 3250'
alias daylight='redshift -x'
alias adb='echo "run me as root dumbass";alias adb="adb" #'
alias pia='sudo bash -c "source /home/duck/Desktop/manual-connections/ENV && /home/duck/Desktop/manual-connections/run_setup.sh"'


# Functions
# =========

# Get IP adress
ipwtf() {
    curl -s https://wtfismyip.com/json | jq
}

# xbps-install fuzzy finder
xs() {
    xpkg -a |
        fzf -m --preview 'xq {1}' \
        --preview-window=right:66%:wrap |
        xargs -ro xi
    }

# history fuzzy finder
hs() {
    cmd=$(history | fzf | cut -c8-)
    echo ${cmd}
    history -s ${cmd}
    eval ${cmd}
}

# List aliases
aliases() {
    # I LOVE SED I LOVE WRITING REGULAR EXPRESSIONS THAT I WILL NEVER BE ABLE
    # TO UNDERSTAND ONCE IM DONE WRITING THEM
    #
    # ok its been 2 years, yeah i cant understand shit and i broke it at some
    # point help

    COL=";" # delimiter for col

    sed -n \
        -e "s|^alias \(.*\)='\(.*\)'|\1${COL}\2|p" \
        -e "/^# .*/ { # search for comments
            N # append a line
            s|# \(.*\)\(.*\)() {|\2()${COL}\1|p
            }
            " \
        -e  "s|\n||g"\
            ${BASH_SOURCE} \
            | sed -e "s/!/\\(\\)/g" \
            | column -tl 2 -s "${COL}"
}

# sync filesystem with external drive
sysbkp() {
    if [[ -e $1 ]]; then
        echo "Syncing ${1} with system"
        rsync -av --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*",\
            "/mnt/*","/media/*","/lost+found"} / ${1}
        else
            echo "media does not exist"
    fi
}

# extract an archive into a correspondingly named directory
unziptodir() {
    # Extract the zip file into a directory named after the original archive
    unzip -q "$1" -d "${1%.zip}"
    mv "$1" "${1%.zip}"
}


# extract an archive into a correspondingly named directory
tarxtodir() {
    # Extract the zip file into a directory named after the original archive
    DIR=${1%.tar*}
    mkdir ${DIR}
    tar xf "$1" --directory="${DIR}"
    mv $1 "${DIR}"/
}

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
