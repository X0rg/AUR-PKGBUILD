#!/bin/bash

# From default pre-commit.sample: warn about whitespace issues
if git rev-parse --verify HEAD >/dev/null 2>&1; then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi
git diff-index --check --cached $against -- 1>&2
[[ $? != "0" ]] && echo -e "\e[01;31mThis commit contains whitespace issues!\e[0m"


# fix environment of githooks
unset GIT_DIR
# make sure .SRCINFO is up to date
for path in $(git diff --name-only --cached --diff-filter=AM); do
    if [[ "${path}" =~ .*/PKGBUILD$ ]]; then
        echo -e "\e[01;32m *** Generating and adding .SRCINFO for ${path%/PKGBUILD} ***\e[00m" 
        cd ${path%PKGBUILD}
        ls -1 > /tmp/fileslist
        (updpkgsums && makepkg --printsrcinfo > .SRCINFO) || exit 1
      
        ls -1 >> /tmp/fileslist
        local todelete=$(sort /tmp/fileslist | uniq -u)
	    if [[ -n $todelete ]]; then
		    echo -e "\e[01;32m *** Cleaning directory ***\e[00m"
		    rm -v $todelete
	    fi

        git add ${path%PKGBUILD}/.SRCINFO
    fi
done
