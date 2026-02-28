#!/usr/bin/env bash

set -euo pipefail
# set -x
top="/home/david/perl-rebuilds/"
pkgs="$(cat "$HOME/perl-pkgs")"

pkgs_updated=""
package_count() {
    echo -e ${pkgs} | wc -w
}
# git fetch origin

# Goes to the root directory of the git repository
function goroot() {
    cd "$(git rev-parse --show-toplevel)" || return 1
}

# Push into a package directory
function gotopkg() {
    cd "$(git rev-parse --show-toplevel)"/packages/*/"$1" || return 1
}

for i in ${pkgs}; do
    gotopkg $i
    rel_path=$(realpath --relative-to "$top" $(pwd))
    old_relnum=$(git -P show origin/main:$rel_path/package.yml | yq '.release' -)
    current_relnum=$(yq '.release' package.yml)

    if [[ "$old_relnum" == "$current_relnum" ]]; then
        go-task bump
    fi

    # echo $i
    # yq '.install' package.yml | grep "qml6_" || true
    # cat pspec_x86_64.xml | grep "\.qml" | head -5 || true

    if compgen -G "*.eopkg" > /dev/null; then
        continue
    fi

    # if [[ -f MAINTAINERS.md ]]; then
    #     rm MAINTAINERS.md
    # fi

    # sed -i 's|6\.7\.0|6.8.0|g' package.yml
    # sed -i 's|frameworks/6\.7|frameworks/6.8|g' package.yml
    # sed -i 's|cdn\.download\.kde\.org|download.kde.org|g' package.yml

    # old_sha=$(git -P show origin/main:$rel_path/package.yml | yq '.source.[0] | to_entries | .[0].value' -)
    # current_sha=$(yq '.source.[0] | to_entries | .[0].value' package.yml)

    # if [[ "$old_sha" == "$current_sha" ]]; then
    #     url=$(yq '.source.[0] | keys | .[0]' package.yml)
    #     temp=$(mktemp)

    #     wget $url -O $temp

    #     new_sha=$(sha256sum $temp | awk '{printf $1}')
    #     rm $temp
    #     current_sha=$(yq '.source.[0] | to_entries | .[0].value' package.yml)
    #     sed -i "s|$current_sha|$new_sha|g" package.yml
    # fi

    go-task build-localcp
    # go-task clean


    if [[ $pkgs_updated =~ (^|[[:space:]])$i($|[[:space:]]) ]]; then
        echo $i
        git add .
        git commit -s
    else
        echo $i
        git add .
        git commit -s -m "$i: Rebuild for perl 5.42"
    fi

    # git add .
    # sed "s|@@PKG@@|$i|g" ~/Solus/worktrees/commit-kf6 | git commit -s -F -
    # git commit -s -m "$i: Rebuild for kernels"

    goroot
done
