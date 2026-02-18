alias vim="nvim"
alias vi="nvim"
alias oldvim="vim"
alias python="python3"

alias ll="ls -la"

alias kubectl="minikube kubectl --"
alias k="kubectl"

alias jr="cd $PROJECTS_DIR/julienrollin/"

alias pr="cd $PROJECTS_DIR/"
alias wd="cd $WORK_DIR/"
alias dot="cd $DOTFILES_DIR/"

# fuzzy search 
alias ff="cd \$(find $PROJECTS_DIR $DOTFILES_DIR $WORK_DIR $PERSO_DIR -mindepth 1 -maxdepth 1 -type d | fzf)"


# check if remote has changed before push force, ok if no changes"
alias gpushf="git push --force-with-lease"
# show diff branch
# src: https://gist.github.com/schacon/e9e743dee2e92db9a464619b99e94eff
# alias gb="git for-each-ref --color --sort=-committerdate --format=$'%(color:red)%(ahead-behind:HEAD)\t%(color:blue)%(refname:short)\t%(color:yellow)%(committerdate:relative)\t%(color:default)%(describe)' refs/heads/ --no-merged | \
#     sed 's/ /\t/' | \
#     column --separator=$'\t' --table --table-columns='Ahead,Behind,Branch Name,Last Commit,Description'
# "
