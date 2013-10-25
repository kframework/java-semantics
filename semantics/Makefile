
kompile:
	kompile -v java

krun:
ifndef PROG
$(error PROG is not set)
endif
	aux-kjrun2.sh --time true --timeout 30 --debug false --display-config true $(PROG)

krun-in:
ifndef PROG
$(error PROG is not set)
endif
	aux-kjrun2.sh --time true --timeout 0 --debug false --display-config true $(PROG)

latex:
	kompile -v --backend latex --doc-style "style=math" java

pdf:
	kompile -v --backend pdf --doc-style "style=math" java

