# :noTabs=false:

all: release/emufun-HEAD.love

release/emufun-HEAD.love: .FORCE
	rm -f $@
	git archive --format=zip --output=$@ HEAD

.FORCE:
