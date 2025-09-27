# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# eval $(cat /home/duck/.profile)
source /home/duck/.profile

# History
export HISTFILESIZE=infinite
export HISTSIZE=1000000
export PROMPT_COMMAND="history -a"
shopt -s histappend

export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

### Aliases
alias ls="exa --icons --group-directories-first"
alias la="ls -a"
alias ll="ls -al"
alias tree="ls --tree"
alias cls="clear"
alias clls="clear; ls"
alias less="less -r"
alias get="curl -OL"
alias cuts="cut -d' '"
alias xai="xargs -I {}"
alias feh="feh -B '#191724'"
alias rpn="dc -e "
alias iv="nsxiv"
alias NEWEST="ls -snew | tail -n 1"
alias OLDEST="ls -snew | head -n 1"
alias NOW_PLAYING="playerctl metadata --format 'artist:{{artist}} title:{{title}}'"
alias sbrc="source ~/.bashrc"
alias brc="nvim ~/.bashrc; wait; sbrc"
alias em="emacs"
alias pls="sudo !!"
alias lpa4="lp -o media=a4"
alias lpa5="lp -o media=a5"
alias lpa6="lp -o media=a6"
alias uztd="unziptodir"
alias txtd="tarxtodir"
alias lzip="unzip -l"
alias ltar="tar tf"
alias cl="sbcl"
alias whisper="espeak -v en+whisper -s 120"
alias news="newsraft"
alias enews="nvim ~/.config/newsraft/feeds"
alias weather="curl -s https://wttr.in?M"
alias adb="echo 'run me as root dumbass';alias adb='adb' #"
alias toclip="xclip -sel clip"
alias clip="xclip -o -sel clip"
alias vencord="sh -c "'$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)'

### Functions

nightlight() {
    # low light mode
    redshift -O 1000K
    feh --no-fehbg --bg-tile ~/Pictures/Wallpapers/tiles/airbrush_tile.png
    brightnessctl s 5%
}

daylight() {
    # !nightlight
    ~/.fehbg
    redshift -x
    brightnessctl s 50%
}

lazyclick() { # $time
    sleep "$1"
    xdotool click 1
}

bt() {
    ## Toggle bluetooth headphones
    device="AC:80:0A:56:78:BA"
    read name paired battery <<<$(bluetoothctl info $device | awk '
        /Name: / { printf "%s ", $2 }
        /Connected: / { printf "%s ", $2 }
        /Battery Percentage: / { printf "%s ", substr($4, 2, length($4 - 2)) }
        ')
    echo $name - $paired - $battery
}

beets_new() {
    ## List recently imported albums
    beet ls ~/Music --album added+ -f '$added;$albumartist;$album' |
        awk '{
            FS=";";
            if (length($2) > 20)
                $2 = substr($2, 1, 20) "...";
            if (length($3) > 25)
                $3 = substr($3, 1, 25) "...";
            printf "%s|%-23s|%-33s\n", $1, $2, $3;
        }'
}

alias bnew="beets_new | cut -d'|' -f2-"

beets_tg() { # $count
    ## List top genres in library
    if [[ -z $1 ]]; then
        count=999
    else
        count=$1
    fi

    beet list ~/Music -f '$genre' |
        sed -e 's/, /\n/g' |
        tr 'A-Z' 'a-z' |
        grep -v '^$' | sort | uniq -c | sort -rn |
        head --lines $count
}

beets_g() { # $query
    ## list genres of a given query
    beet list genre:"$@" -f '$genre; $album; $artist' | uniq |
        awk -F "; " '{ print $1 " | " $2 " | " $3}'
}

beets_lyrics() { # $query
    ## display the lyrics for a given track
    query="$1"
    if [[ -z $query ]]; then
        query=$(NOW_PLAYING)
    fi
    lyrics=$(beet info --format '$lyrics' ${query})
    if [[ -z $lyrics ]]; then
        echo "fetching lyrics..."
        beet lyrics ${query}
    lyrics=$(beet info --format '$lyrics' ${query})
    fi
    echo "${lyrics}" \
        | perl -pe 's/.*Contributors//; s/Lyrics\[/\n\n\[/g'
}

browse() {
    ## browse albums by album cover
    fd 'cover.(jpg|png)' ~/Music |
        nsxiv -btioq -g 600x450 |
        awk -F'/[^/]*$' '{print $1}'
}

autnorm() { # $input
    ## peak normalize audio to 0db
    input="${1}"
    echo "$input \n ${input%%.*} \n ${input##*.}"
    ffmpeg -i "${input}" \
        -af "loudnorm=I=-16:TP=0.0:LRA=11:print_format=summary" \
        -c:a pcm_s16le "${input%%.*}_0db.${input##*.}"
}

ihatewebp() {
    ## i hate webp.
    magick '*.webp' -set filename:f "%t" '%[filename:f].jpg' && rm *.webp
}

ripcd() { # $format (default is flac)
    ## Cyanrip wrapper
    if [[ -z $1 ]]; then
        format="flac"
    else
        format=$1
    fi

    echo "finding offset..."
    offset=$(cyanrip -f | awk '/^Drive offset of/ {print $4}')
    echo "offset of" "${offset}"

    cyanrip -Q -s ${offset} -o ${format}
}

burncd() { # $image.iso
    ## burn iso to disk
    cdrecord -v -sao "$1"
}

vpn() {
    ## Connect to PIA
    sudo bash -c 'cd /home/duck/Desktop/manual-connections &&
        source /home/duck/Desktop/manual-connections/ENV &&
        /home/duck/Desktop/manual-connections/run_setup.sh'
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

flathub() {
    ## install apps from Flathub
    URL='https://flathub.org/api/v2/appstream'
    package=$(
        curl "${URL}" | jq -r '.[]' |
            fzf -m --preview "curl -s ${URL}/{1} |
        jq -r '.name, .id, .summary, .project_license, .version,
            .developer_name, .urls.homepage'"
    )
    if [[ -n "${package}" ]]; then
        flatpak install -u flathub "${package}"
    fi
}

hs() {
    ## history fuzzy finder
    cmd=$(history | fzf | cut -c8-)
    echo ${cmd}
    history -s ${cmd}
    eval ${cmd}
}

histtop() {
    ## View top 50 commands
    history |
        awk '{CMD[$2]++;count++;}END {
        for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' |
        grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n50
}

histclip() {
    ## Copy last command to clipboard
    history 2 | cut -d' ' -f3- | xclip -sel clip
}

op() {
    ## fzf + zathura
    file=$(fd --extension pdf . |
        fzf --scheme=path --preview 'pdfinfo {}')
    if [[ -n ${file} ]]; then
        nohup zathura "${file}" >&/dev/null &
        op
    fi
}

simplify_text() { # $filename
    ## replace "fancy" typographic characters with ASCII
    sed -E '
    s/“|”|„|«|»/"/g; # replace fancy quotes with plain double quote
    s/‘|’|‚/`/g;     # replace fancy single quotes with plain backtick or single quote
    s/–|—/-/g;       # replace en dash and em dash with plain hyphen
    s/…/.../g;       # replace ellipsis with three dots
    s/©/(c)/g;       # replace copyright symbol with (c)
    s/®/(r)/g;       # replace registered symbol with (r)
    s/™/(tm)/g;      # replace trademark symbol with (tm)
    s/·|•|‣|∙|⋅/-/g; # replace bullets with plain hyphen or similar character
    s/¼/1\/4/g;      # replace fractions with ASCII representations
    s/½/1\/2/g;
    s/¾/3\/4/g;
    ' "$1" | iconv -f utf-8 -t ascii//TRANSLIT
}

text2sig() { # $title $filename
    ## convert plaintext files into ready-to-print book signatures
    title=$1
    filepath=$2
    filename=$(basename "${filepath}")
    simplify_text "${filepath}" |
        enscript -1 --media=A4 --word-wrap \
            --non-printable-format=questionmark \
            --margins=40:20:20:20 \
            --swap-even-page-margins \
            -J "${title}" --header='|'"${title}"'|$%/$=' -p - >"${filename%.*}.ps"
    # psbook -s16 > "${filename%.*}.ps"
    # psbook -s16 | psnup -2 -pa4 -Pa3 > "${filename%.*}.ps"
    ps2pdf "${filename%.*}.ps"
    # pdfjam --nup 2x1 --paper a4paper --outfile "${filename%.*}_folio.pdf" "${filename%.*}.pdf"
    echo "${filename%.*}.ps" "${filename%.*}.pdf"
}

rm_brokenlinks() { # $dir
    ## remove broken symlinks
    dir="$1"
    find -maxdepth 1 -type l -delete -L "${dir}"
}

svenable() {
    ## fzf wrapper for enabling services
    SERVICE_DIR="/etc/sv"
    ACTIVE_SERVICE_DIR="/var/service"
    service=$(fd -d 1 -t d . "${SERVICE_DIR}" | fzf)
    echo enable "${service}"
    sudo ln -s "${service}" "${ACTIVE_SERVICE_DIR}"
}

svdisable() {
    ## fzf wrapper for disabling services
    ACTIVE_SERVICE_DIR="/var/service /home/duck/.local/service"
    service=$(fd -t l . ${ACTIVE_SERVICE_DIR} | fzf)
    echo disable "${service}"
    sudo rm "${service}"
}

svreload() {
    ## fzf wrapper for reloading services
    ACTIVE_SERVICE_DIR="/var/service"
    service=$(fd -t l . "${ACTIVE_SERVICE_DIR}" | fzf)
    echo reload "${service}"
    sudo sv reload "${service}"
}

svstatus() {
    ## see status of enabled services
    SYSTEM_SERVICE_DIR="/var/service"
    LOCAL_SERVICE_DIR="$HOME/.local/service"

    reset=$(color -c reset -m "")
    ok_style=$(color -c green -m "")
    warning_style=$(color -c yellow -m "")
    down_style=$(color -c red -m "")

    function format() {
        sed '
        s/^run/'$ok_style'&'$reset'/
        s/^down/'$down_style'&'$reset'/
        s/^warning/'$warning_style'&'$reset'/
        '
    }

    sudo sv status $SYSTEM_SERVICE_DIR/* | format
    printf "\nLocal Services\n"
    sv status $LOCAL_SERVICE_DIR/* | format
}

web_docs() {
    ## HTML, CSS, JS, and SVG documentation
    fd . ~/Documents/web_docs/ --extension html |
        fzf -m |
        xargs lynx
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
        if ($1 != "function") {
        split($0, a, "#")
        {print "'$f_style' " $1 "'$reset$dim'"a[2]""}
        {getline}
        sub(" *#* *", "")
        {print " '$reset'| " $0}
        }
    }
    /^alias / {
        gsub("\"", "")
        sub("alias ", "")
        sub("=", " ")
        printf("'$a_style' %-10s'$reset' '$dim'%s'$reset'\n",
            $1, substr($0, length($1) + 1))
        # print $0
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
        rsync -auLhP --delete $HOME ${1} &&
            echo "Last synced" $(date) >$1/backup_info
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
    unzip -q "$1" -d "${1%.zip}" &&
        rm "$1"
    # mv "$1" "${1%.zip}"
}

tarxtodir() { # $archive.tar.gz
    ## extract an archive into a correspondingly named directory
    # if [[ "$1" != *.tar.gz ]]; then
    #     echo "not a tar archive."
    #     return 1
    # fi
    DIR=${1%.tar*}
    mkdir ${DIR}
    tar xf "$1" --directory="${DIR}" &&
        rm "$1"
    # mv "$1" "${DIR}"/
}

installfont() { # $font.zip
    ## extract a zip file and copy it to ~/.local/share/fonts
    path=$1
    unziptodir ${path}
    mv ${path%.zip} ~/.local/share/fonts
    echo ${path%.zip} " extracted and moved to local fonts"

}

function conditional_asdf() {
    if [ ! -f "$PWD/.tool-versions" ]; then
        export PATH=$(echo $PATH | sed -E 's/(.*)\.asdf([^:]*)://')
    else
        cat "$PWD/.tool-versions"
        export PATH="${HOME}/.asdf/shims:${HOME}/.asdf/bin:${PATH}"
    fi
}
# Plugin Setup
eval "$(zoxide init bash)"
eval "$(direnv hook bash)"
eval "$(rbenv init - bash)"
eval "$(starship init bash)"

PROMPT_COMMAND="conditional_asdf; $PROMPT_COMMAND"

# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then
    source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
fi
# END_KITTY_SHELL_INTEGRATION

# BEGIN_WEZTERM_SHELL_INTEGRATION
WEZINIT="$HOME/.config/wezterm"
if test -n "${WEZINIT}" -a -e "${WEZINIT}/wezterm.sh"; then
    source "${WEZINIT}/wezterm.sh"
fi
# END_WEZTERM_SHELL_INTEGRATION

export _ZO_DOCTOR=0
