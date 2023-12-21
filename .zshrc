# shellcheck disable=SC1091,SC2155

setopt appendhistory
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"
fpath+=~/.zfunc

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH # % compaudit | xargs chmod g-w
  
    autoload -Uz compinit
    compinit
    export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/games:/usr/games:$HOME/.local/bin:$HOME/go/bin

    source $(brew --prefix)/share/zsh/site-functions
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/usr/local/games:/usr/games:$HOME/.local/bin
fi

autoload -U bashcompinit
bashcompinit
autoload -U promptinit
promptinit

# set jtool2 colour output
if type jtool2 &>/dev/null
then
    export JCOLOR=1
fi

# macos or iphoneos sdk paths
XCRUN=$(which xcrun)
if [ ! -z $XCRUN ];
then
    export macosx_sdk="$($XCRUN --show-sdk-path -sdk macosx)/"
    export iphoneos_sdk="$($XCRUN --show-sdk-path -sdk iphoneos)/"
fi

# llvm
test -d "$(brew --prefix)/Cellar/llvm/" && export llvms="$(brew --prefix)/Cellar/llvm/"

# kdk path
test -d "/Library/Developer/KDKs/" && export kdks="/Library/Developer/KDKs/"

# device Support
test -d "${HOME}/Library/Developer/Xcode/iOS DeviceSupport" && export devicesupport="${HOME}/Library/Developer/Xcode/iOS DeviceSupport"

# the prompt
if [ -f "${HOME}/.abbr_pwd" ]
then
    source "${HOME}/.abbr_pwd"
    
    git_info() {
	branch=$(git symbolic-ref -q --short HEAD 2>/dev/null)
	if [ -n "$branch" ]; then
            echo "$branch"
            return
	fi

	tag=$(git describe --tags --exact-match --abbrev=0 HEAD 2>/dev/null)
	if [ -n "$tag" ]; then
            echo "$tag"
            return
	fi

	commit=$(git rev-parse --short HEAD)
	echo "$commit"
    }


    precmd() {
        # if [ "$TERM_PROGRAM" = "iTerm.app" ]
        # then
        #    # Needed because of this: https://gitlab.com/gnachman/iterm2/-/issues/8755
        #    window_title="\e]0;$(pwd_abbr)\a"
        #    echo -ne "$window_title"
        #    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
        # fi

        if [ -d ".git" ] && [ $VIRTUAL_ENV ]
        then
            export PS1="%F{8}[%F{3}$(pwd_abbr)%F{8} %f$(basename $VIRTUAL_ENV) %f$(git_info)%F{8}]%% %f"
	    PATH="$VIRTUAL_ENV/bin:$PATH"
        elif [ $VIRTUAL_ENV ]
        then
    	    export PS1="%F{8}[%F{3}$(pwd_abbr)%F{8} %f$(basename $VIRTUAL_ENV)%F{8}]%% %f"
	    PATH="$VIRTUAL_ENV/bin:$PATH"
        elif [ -d ".git" ]
        then
            export PS1="%F{8}[%F{3}$(pwd_abbr)%F{8} %f$(git_info)%F{8}]%% %f"
        else
	    export PS1="%F{8}[%F{3}$(pwd_abbr)%F{8}]%% %f"
        fi
    }
else
    # export PS1="%F{8}[%F{4}%~%F{8}]%% %f"
    export PS1="%F{8}[%F{3}%~%F{8}]%% %f"
fi

# my aliases & functions
test -e "${HOME}/.functions" && source "${HOME}/.functions"
test -e "${HOME}/.aliases" && source "${HOME}/.aliases"

# golang
test -d "${HOME}/go/" && export GOPATH="${HOME}/go/"

# for grc command colours
test -e "${HOME}/.grc.zsh" && source "${HOME}/.grc.zsh"

# ripgrep settings
test -e "${HOME}/.ripgrep"  && export RIPGREP_CONFIG_PATH="${HOME}/.ripgrep"

# for fzf
test -e "${HOME}/.fzf.zsh" && source "${HOME}/.fzf.zsh"

# virtualenvwrapper
test -e "$(brew --prefix)/bin/virtualenvwrapper.sh" && source "$(brew --prefix)/bin/virtualenvwrapper.sh" >/dev/null \
							      && test -d "${HOME}/.virtualenvs" || mkdir -p "${HOME}/.virtualenvs" \
							      && test -d "${HOME}/.virtualenvs" && export WORKON_HOME="${HOME}/.virtualenvs"

# use bat for less
if type bat &>/dev/null
then
    if [ -f $(bat --config-dir)/themes/Catppuccin-mocha.tmTheme ]
    then
	export MANPAGER="sh -c 'col -bx | bat --theme Catppuccin-mocha -l man -p'"
    else
	export MANPAGER="sh -c 'col -bx | bat --theme Nord -l man -p'"
    fi
fi

# for pyenv
if type pyenv &>/dev/null
then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# for pipx
if type pipx &>/dev/null
then
    eval "$(register-python-argcomplete pipx)"
fi

# for nvm
if [ -f "$(brew --prefix)/opt/nvm/nvm.sh" ]
then
    if [ ! -d "${HOME}/.nvm" ]
    then
        mkdir -p "${HOME}/.nvm"
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && 
        \. "$(brew --prefix)/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && 
        \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

# rg config
if type rg &>/dev/null
then
    CONFIGFILE="${HOME}/.ripgrep"
    if [ -f $CONFIGFILE ]
    then
cat <<EOF > $CONFIGFILE
# --max-columns=150
# --max-columns-preview
# --smart-case
# --colors=column:none
# --colors=column:fg:4
# --colors=column:style:underline

# --colors=line:none
# --colors=line:fg:4

# --colors=match:none
# --colors=match:bg:0
# --colors=match:fg:6

# --colors=path:none
# --colors=path:fg:14
# --colors=path:style:bold
EOF
    fi
fi
# tmux config
CONFIGFILE="${HOME}/.tmux.conf"
if [ ! -f $CONFIGFILE ]
then
cat <<EOF >$CONFIGFILE
set -g default-terminal screen-256color
set-option -g status-interval 1
set-option -g automatic-rename on
set-option -g automatic-rename-format '#{b:pane_current_path}'
set-option -g set-titles on
set-option -g set-titles-string '#{b:pane_current_path} - #{pane_current_command}'

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

# nord theme
# set -g @plugin "arcticicestudio/nord-tmux"

# catppuccin theme
set -g @plugin 'catppuccin/tmux'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
mkdir -p "${HOME}/.tmux"
fi

# inside Terminal.app 
# if we have a default tmux session attach to it, else start a new one
if [[ "$TERM_PROGRAM" = "Apple_Terminal" && -z "$INSIDE_EMACS" ]]
then
    if type tmux &>/dev/null
    then
	if [[ $(tmux list-sessions -F '#{session_name}' 2>/dev/null ) == 0 ]]
	then
	    tmux attach
	else
	    tmux new
	fi
    fi
fi
