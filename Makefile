# :noTabs=false:
FILES=$(shell find -name '*.lua' -or -name '*.cfg') images/* COPYING README

all: release/emufun-HEAD.love

release/emufun-HEAD.love: ${FILES}
	rm -f $@
	zip $@ $+
