# Remove all local changes from your working copy
#
# https://stackoverflow.com/questions/14318234/how-to-ignore-error-on-git-pull-about-my-local-changes-would-be-overwritten-by-m
#
git stash save --keep-index
git stash drop

