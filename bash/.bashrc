###############
### History ###
###############

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=50000
HISTTIMEFORMAT="%d/%m/%y %T "

###############
### Aliases ###
###############

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='ggrep --color=auto'
alias fgrep='gfgrep --color=auto'
alias egrep='gegrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# kube prompt
alias ko="gsed -i '/kubernetes/{ n; s/true/false/g }' ~/.config/starship.toml"
alias kboff="gsed -i '/kubernetes/{ n; s/false/true/g }' ~/.config/starship.toml"

# kube related
alias kgp="kubectl get pods -o wide | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}' | column -t"

# gcloud
alias gauth='gcloud projects list > /dev/null'

#################
### Functions ###
#################

# git diff with fzf
fd() {
  git diff $@ --name-only --relative -- ':!*secrets.auto.tfvars' | fzf --height=80% -m --ansi --preview 'git diff $@ --color=always -- {-1}'
}

# cleanup terragrunt cache
cleanup-terragrunt-cache() {
	echo -e "\n\033[1mClearing terragrunt cache...\033[0m\n"
    find . -type d -name ".terragrunt-cache" -prune -exec bash -c "echo 'Clearing folder: {}' && rm -rf {}" \;
	echo -e "\n\033[32mComplete!\033[0m\n"
}

# cleanup terraform cache/locks etc..
cleanup-terraform-locks() {
	echo -e "\n\033[1mClearing terraform lock files...\033[0m\n"
    find . -type f -name ".terraform.lock.hcl" -prune -exec bash -c "echo 'Clearing file: {}' && rm -rf {}" \;
	echo -e "\n\033[32mComplete!\033[0m\n"
}

# cleanup terraform/terragrunt stuff (cache/locks etc..)
cleanup-iac() {
    cleanup-terraform-locks
    cleanup-terragrunt-cache
}

# kubectl watch pods
kwatch() {
    if [ -z $1 ] 
    then
        watch kubectl get po
    else
        watch "kubectl get pods -o wide | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}' | column -t | grep -i $1"
    fi    
}

# cleanup (pull latest master from origin, delete gone branches, run gc) all Workable's repos
gitcleanup-workable() {
    echo -e "\033[33m#### This script syncs all workable related repos with the origin ####\033[0m"
    echo -e "\n\033[31mWARNING:\033[0m Not commited changes will be removed."
    read -p 'Are you sure you want to continue (y/n): ' answer1

    if [ "$answer1" == "y" ] 
    then
        sleep 2s
	    CUR_DIR=$(pwd)
 	    echo -e "\n\033[1mPulling the latest changes for all Workable's repositories...\033[0m"
	    for i in $(find ~/git-repos/Workable -name ".git" | sed -e 's/.git$//'); do
        		echo "";
        		echo -e "\033[33m"--\>$i"\033[0m";
	    	cd "$i";
            echo -e "\033[35m"Fetch and sync with remote.."\033[0m";
            # get the base branch (master or main)
            local base_branch=$(git remote show origin | grep -oP "HEAD branch:\s+\K.*")
            git checkout ${base_branch};
            git fetch --all -p -P;
            git reset --hard origin/${base_branch};
            git clean -f -d
            echo -e "\033[35m"Delete local branches that are gone on remote.."\033[0m";
            git gone;
            echo -e "\033[35m"Run git gc.."\033[0m";
	    	git gc;
	    	cd $CUR_DIR
	    done
	    echo -e "\n\033[32mComplete!\033[0m\n"
    fi
}

#######################
### Autocompletions ###
#######################

# gcloud plugins
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"

# k8s related
source <(kubectl completion bash)
source <(helm completion bash)
source <(stern --completion=bash)
source <(flux completion bash)

# terraform/terragrunt
complete -C /usr/local/bin/terraform terraform
complete -C /usr/local/bin/terraform terragrunt

# fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# github cli
eval "$(gh completion -s bash)"

################
# Use starship #
################
eval "$(starship init bash)"

complete -A directory cdgitworkable

# z fast jump-list directories
. ~/z.sh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
