#!/bin/bash
# shellcheck disable=SC2048

GITURL="https://github.com/jthorpe6/shellenv.git"
declare -a dotfiles=(".abbr_pwd" ".aliases" ".functions" ".grc.zsh" ".zshrc" ) 

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
