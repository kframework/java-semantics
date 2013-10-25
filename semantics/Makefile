
kompile:
	kompile -v java

krun:
ifndef PROG
$(error PROG is not set)
endif
	aux-kjrun2.sh --time true --timeout 30 --debug false --display-config true $(PROG)

# The argument timeout don't work properly for programs that accept input. For this reason we need a special make target
# for programs that read from stdin.
krun-in:
ifndef PROG
$(error PROG is not set)
endif
	aux-kjrun2.sh --time true --timeout 0 --debug false --display-config true $(PROG)

latex:
	kompile -v --backend latex --doc-style "style=math" java

pdf:
	kompile -v --backend pdf --doc-style "style=math" java

