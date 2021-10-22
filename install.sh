#!/bin/bash

DOT_DIR="$HOME/dotfiles"

has() {
    type "$1" > /dev/null 2>&1
}

if if [ ! -d {DOT_DIR} ]; then
    if type "git"> /dev/null 2>&1; then
        git clone https://github.com/AyamotoKohei/dotfiles.git ${DOT_DIR}
    elif type "curl"> /dev/null 2>&1 || type "wget"> /dev/null 2>&1; then
        TARBALL="https://github.com/AyamotoKohei/dotfiles/archive/refs/heads/main.tar.gz"
        if type "curl" /dev/null 2>&1; then
            curl -L ${TARBALL} -o main.tar.gz
        else
            wget ${TARBALL}
        fi
        tar -zxvf main.tar.gz
        rm -f main.tar.gz
        mv -f dotfiles-main "${DOT_DIR}"
    else
        echo "curl or wget or git required"
        exit 1
    fi

    cd ${DOT_DIR}

    for f in *;
    do
        [[ "$f" == ".git" ]] && continue
        [[ "$f" == ".gitignore" ]] && continue
        [[ "$f" == ".DS_Store" ]] && continue
        [[ "$f" == "README.md" ]] && continue
        [[ "$f" == "install.sh" ]] && continue

        ln -snf $DOT_DIR/"$f" $HOME/"$f"

        echo "installed $f"
    done
else
    echo "dotfiles already exists"
    exit 1
fi
