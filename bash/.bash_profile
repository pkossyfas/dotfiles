# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export LANG=en_US.UTF-8

export BASH_SILENCE_DEPRECATION_WARNING=1
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

complete -C /usr/local/bin/vault vault
