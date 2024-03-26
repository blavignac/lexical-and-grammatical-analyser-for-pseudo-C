all: c

yacc: c.tab.c c.tab.h

c.tab.c c.tab.h: c.y
	bison -t -v -d c.y

lex.yy.c: c.l c.tab.h
	flex c.l

c: lex.yy.c c.tab.c c.tab.h manip.c manip.h
	gcc -o c c.tab.c lex.yy.c manip.c

test: all 
	

clean:
	rm c c.tab.c lex.yy.c c.tab.h c.output 2> /dev/null