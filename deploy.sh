#!/bin/bash

ZIP="zip -db -dc -q"
UNZIP="unzip -q -o"
BRANCHES="master dev"
SRC="$(git ls-files | egrep -v ^examples/)"

function main() {
  prepare
  [[ $@ ]] || set -- make-love make-win32 make-win64 make-osx deploy
  while [[ $1 ]]; do
    for branch in $BRANCHES; do
      $1 $branch
    done
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
  for arch in macosx-ub win-x86 win-x64; do
    rm -rf ".build/love-0.8.0-$arch"
    [[ -f ".build/love-0.8.0-$arch.zip" ]] || wget -q -P .build "https://bitbucket.org/rude/love/downloads/love-0.8.0-$arch.zip"
  done
}

function make-love() {
  echo "Making emufun-$1.love"
  local name="release/emufun-$1.love"
  rm -f "$name"
  git archive --format=zip --output="$name" "$1"
}

function make-osx() {
  echo "Making emufun-osx-$1.zip"
  ${UNZIP} -d .build .build/love-0.8.0-macosx-ub.zip
  mv .build/love.app .build/emufun.app
  cp "release/emufun-$1.love" .build/emufun.app/Contents/Resources/
  cp Info.plist .build/emufun.app/Contents/
  (cd .build && ${ZIP} -r "../release/emufun-osx-$1.zip" emufun.app)
  rm -rf .build/emufun.app
}

function make-win() {
  ${UNZIP} -d .build ".build/love-0.8.0-win-$2.zip"
  mv ".build/love-0.8.0-win-$2" .build/emufun
  cat "release/emufun-$1.love" .build/emufun/love.exe > .build/emufun/emufun.exe
  rm .build/emufun/love.exe
  (cd .build && ${ZIP} -r emufun.zip emufun/)
  rm -rf .build/emufun
}

function make-win32() {
  echo "Making emufun-win32-$1.zip"
  make-win $1 x86
  mv .build/emufun.zip "release/emufun-win32-$1.zip"
}

function make-win64() {
  echo "Making emufun-win64-$1.zip"
  make-win $1 x64
  mv .build/emufun.zip "release/emufun-win64-$1.zip"
}

function deploy() {
  echo "Deploying emufun-$1.love to orias"
  cp release/*.love /orias/media/EmuFun/
}

main "$@"
## end
