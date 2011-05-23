# :noTabs=false:
SRCS=*.lua

all: emufun.love

emufun.love: ${SRCS}
	zip emufun.love ${SRCS}
