# :noTabs=false:
# TODO: get someone to test the OSX build; figure out what is needed to
# integrate LFS into it.
# TODO: automatically download LFS DLLs and integrate into windows builds.

ZIP=zip -db -dc -q
UNZIP=unzip -q

SRC=$(shell git ls-files | egrep -v ^examples/)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

all: dirs love osx win32 win64
love: release/emufun.love
osx: release/emufun-osx.zip
win32: release/emufun-win32.zip
win64: release/emufun-win64.zip

dirs:
	mkdir -p .build release

clean:
	rm -rf .build release

release/emufun.love: ${SRC}
	rm -f $@
	git archive --format=zip --output=$@ HEAD

release/emufun-osx.zip: love2d-bin-osx love
	${UNZIP} -d .build .build/love-0.8.0-macosx-ub.zip
	mv .build/love.app .build/emufun.app
	cp release/emufun.love .build/emufun.app/Contents/Resources/
	cp Info.plist .build/emufun.app/Contents/
	cd .build && ${ZIP} -r ../release/emufun-osx.zip emufun.app
	rm -rf .build/emufun.app

release/emufun-win32.zip: love2d-bin-win32 love
	${UNZIP} -d .build .build/love-0.8.0-win-x86.zip
	mv .build/love-0.8.0-win-x86 .build/emufun
	cat release/emufun.love .build/emufun/love.exe > .build/emufun/emufun.exe
	rm .build/emufun/love.exe
	cd .build && ${ZIP} -r ../release/emufun-win32.zip emufun/
	rm -rf .build/emufun

release/emufun-win64.zip: love2d-bin-win64 love
	${UNZIP} -d .build .build/love-0.8.0-win-x64.zip
	mv .build/love-0.8.0-win-x64 .build/emufun
	cat release/emufun.love .build/emufun/love.exe > .build/emufun/emufun.exe
	rm .build/emufun/love.exe
	cd .build && ${ZIP} -r ../release/emufun-win64.zip emufun/
	rm -rf .build/emufun

love2d-bin-osx: .build/love-0.8.0-macosx-ub.zip
.build/love-0.8.0-macosx-ub.zip:
	wget -q -P .build https://bitbucket.org/rude/love/downloads/love-0.8.0-macosx-ub.zip

love2d-bin-win32: .build/love-0.8.0-win-x86.zip
.build/love-0.8.0-win-x86.zip:
	wget -q -P .build https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.zip

love2d-bin-win64: .build/love-0.8.0-win-x64.zip
.build/love-0.8.0-win-x64.zip:
	wget -q -P .build https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x64.zip
