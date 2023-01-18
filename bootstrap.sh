#!/bin/bash
# shellcheck disable=SC2048

function setup_iterm2(){
    if type brew &>/dev/null
    then
        brew install --cask iterm2
    else 
        echo -e " brew not found, not installing iterm2"
    fi

    curl -s https://raw.githubusercontent.com/arcticicestudio/nord-iterm2/develop/src/xml/Nord.itermcolors \
        -o "${HOME}/Downloads/Nord.itermcolors"
    open https://github.com/arcticicestudio/nord-iterm2#installation
}

GITURL="https://github.com/jthorpe6/shellenv.git"
declare -a dotfiles=(".abbr_pwd" ".aliases" ".functions" ".grc.zsh" ".procs.toml" ".zshrc" ) 

if type git &>/dev/null
then
    git clone $GITURL "${HOME}/.shellenv"
    for file in ${dotfiles[*]}
    do
        if [ -f "${HOME}/${file}" ]
        then
            mv "${HOME}/${file}" "${HOME}/${file}.bak"
        fi
        ln -s "${HOME}/.shellenv/${file}" "${HOME}/${file}"
    done
else
    echo -e "[!] git not installed"
    exit
fi

# if iterm2 is not installed, attempt to install it, and download the theme
if [ ! -d "/Applications/iTerm.app" ]
then
    setup_iterm2
fi