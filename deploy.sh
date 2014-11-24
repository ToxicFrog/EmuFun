#!/bin/bash

ZIP="zip -db -dc -q"
UNZIP="unzip -q -o"
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SRC="$(git ls-files | egrep -v ^examples/)"
LOVE="0.9.1"

function main() {
  prepare
  [[ $@ ]] || set -- make-love make-win32 make-win64 make-osx deploy
  while [[ $1 ]]; do
    $1 $BRANCH
    shift
  done
  echo "Done."
}

function debug() {
  set -x
}

function prepare() {
  echo "Preparing build environment"
  mkdir -p .build release
  rm -rf .build/emufun*
  for arch in macosx-x64 win32 win64; do
    rm -rf ".build/love-$LOVE-$arch"
    [[ -f ".build/love-$LOVE-$arch.zip" ]] || {
      echo "Downloading love-$LOVE-$arch"
      wget -nv -P .build "https://bitbucket.org/rude/love/downloads/love-$LOVE-$arch.zip"
    }
  done
  [[ -f ".build/lfs.dll" ]] || {
    echo "Downloading lfs.dll and patching with correct DLL name"
    wget -nv -c -nc -P .build "http://files.luaforge.net/releases/luafilesystem/luafilesystem/luafilesystem-1.4.2/luafilesystem-1.4.2-win32-lua51.zip"
    unzip -j -d .build .build/luafilesystem-1.4.2-win32-lua51.zip
    dd if=<(printf 'lua51.dll\x00') of=.build/lfs.dll seek=9564 bs=1 conv=notrunc
  }
}

function make-love() {
  echo "Making emufun-$1.love"
  local name="release/emufun-$1.love"
  rm -f "$name"
  git archive --format=zip --output="$name" "$1"
  $ZIP "$name" util/*
}

function make-osx() {
  echo "Making emufun-osx-$1.zip"
  ${UNZIP} -d .build .build/love-$LOVE-macosx-x64.zip
  mv .build/love.app .build/emufun.app
  cp "release/emufun-$1.love" .build/emufun.app/Contents/Resources/
  cp Info.plist .build/emufun.app/Contents/
  (cd .build && ${ZIP} -r "../release/emufun-osx-$1.zip" emufun.app)
  rm -rf .build/emufun.app
}

function make-win() {
  ${UNZIP} -d .build ".build/love-$LOVE-$2.zip"
  mv ".build/love-$LOVE-$2" .build/emufun
  cp .build/lfs.dll .build/emufun/
  cat .build/emufun/love.exe "release/emufun-$1.love" > .build/emufun/emufun.exe
  rm .build/emufun/love.exe
  chmod a+x .build/emufun/*.{exe,dll}
  (cd .build && ${ZIP} -r emufun.zip emufun/)
  rm -rf .build/emufun
}

function make-win32() {
  echo "Making emufun-win32-$1.zip"
  make-win $1 win32
  mv .build/emufun.zip "release/emufun-win32-$1.zip"
}

# We don't have a 64-bit binary for lfs.dll. This is disabled until we do.
# function make-win64() {
#   echo "Making emufun-win64-$1.zip"
#   make-win $1 win64
#   mv .build/emufun.zip "release/emufun-win64-$1.zip"
# }

function deploy() {
  echo "Deploying binaries to orias"
  cp -uv release/* /orias/media/EmuFun/
}

main "$@"
## end
