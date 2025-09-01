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

    source "$(brew --prefix)"/share/zsh/site-functions
    source "$(brew --prefix)"/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source "$(brew --prefix)"/share/zsh-autosuggestions/zsh-autosuggestions.zsh
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
if [ -n "$XCRUN" ];
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


    # precmd() {
    #     if [ -d ".git" ] && [ $VIRTUAL_ENV ]
    #     then
    #         export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7} %F{2}$(basename $VIRTUAL_ENV) %F{2}$(git_info)%F{7}]%% %f"
    # 	    PATH="$VIRTUAL_ENV/bin:$PATH"
    #     elif [ $VIRTUAL_ENV ]
    #     then
    # 	    export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7} %F{2}$(basename $VIRTUAL_ENV)%F{7}]%% %f"
    # 	    PATH="$VIRTUAL_ENV/bin:$PATH"
    #     elif [ -d ".git" ]
    #     then
    #         export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7} %F{2}$(git_info)%F{7}]%% %f"
    #     else
    # 	    export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7}]%% %f"
    #     fi
    # }

    precmd() {
	local dir="$PWD"
	local git_dir=""
	while [ "$dir" != "/" ]; do
            if [ -d "$dir/.git" ]; then
		git_dir="$dir"
		break
            fi
            dir="$(dirname "$dir")"
	done

	if [ -n "$git_dir" ]; then
            local virtual_env=""
            if [ -n "$VIRTUAL_ENV" ]; then
		virtual_env="%F{2}$(basename "$VIRTUAL_ENV")%f "
		PATH="$VIRTUAL_ENV/bin:$PATH"
            fi
            local git_info=""
            if branch=$(git -C "$git_dir" symbolic-ref -q --short HEAD 2>/dev/null); then
		git_info="$branch"
            elif tag=$(git -C "$git_dir" describe --tags --exact-match --abbrev=0 HEAD 2>/dev/null); then
		git_info="$tag"
            else
		git_info="$(git -C "$git_dir" rev-parse --short HEAD)"
            fi
            export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7} $virtual_env%F{2}$git_info%F{7}]%% %f"
	else
            if [ -n "$VIRTUAL_ENV" ]; then
		export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7} %F{2}$(basename "$VIRTUAL_ENV")%F{7}]%% %f"
		PATH="$VIRTUAL_ENV/bin:$PATH"
            else
		export PS1="%F{7}[%F{7}$(pwd_abbr)%F{7}]%% %f"
            fi
	fi
    }
else
    # export PS1="%F{8}[%F{4}%~%F{8}]%% %f"
    export PS1="%F{7}[%F{7}%~%F{7}]%% %f"
fi

# my aliases & functions
test -e "${HOME}/.functions" && source "${HOME}/.functions"
test -e "${HOME}/.aliases" && source "${HOME}/.aliases"

# gnu-sed is needed for some emacs things
test -d "$(brew --prefix)/opt/gnu-sed/libexec/" && export PATH="$PATH:$(brew --prefix)/opt/gnu-sed/libexec/"

# mac pdflatex
test -d "/usr/local/texlive/2025basic/bin/universal-darwin/" && export PATH="$PATH:/usr/local/texlive/2025basic/bin/universal-darwin/"

# golang
test -d "${HOME}/go/" && export GOPATH="${HOME}/go/"

# rust
test -d "${HOME}/.cargo/bin" && PATH="$PATH:${HOME}/.cargo/bin"

# for grc command colours
test -e "${HOME}/.grc.zsh" && source "${HOME}/.grc.zsh"

# ripgrep settings
test -e "${HOME}/.ripgrep"  && export RIPGREP_CONFIG_PATH="${HOME}/.ripgrep"

# for fzf
test -e "${HOME}/.fzf.zsh" && source "${HOME}/.fzf.zsh" && source <(fzf --zsh)

# virtualenvwrapper
test -e "$(brew --prefix)/bin/virtualenvwrapper.sh" && \
    source "$(brew --prefix)/bin/virtualenvwrapper.sh" >/dev/null \
    && test -d "${HOME}/.virtualenvs" || mkdir -p "${HOME}/.virtualenvs" \
	    && test -d "${HOME}/.virtualenvs" && export WORKON_HOME="${HOME}/.virtualenvs"

# use bat for less
if type bat &>/dev/null
then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# for pyenv
if type pyenv &>/dev/null
then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
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

if type zoxide &>/dev/null
then
    eval "$(zoxide init zsh)"
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

set-option -g status-style "bg=white,fg=black"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
mkdir -p "${HOME}/.tmux"
fi
