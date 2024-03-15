all: c

yacc: c.tab.c c.tab.h

c.tab.c c.tab.h: c.y
	bison -t -v -d c.y

lex.yy.c: c.l c.tab.h
	flex c.l

c: lex.yy.c c.tab.c c.tab.h
	gcc -o c c.tab.c lex.yy.c

test: clean all
	./c < ./samples/ok10.c

clean:
	rm c c.tab.c lex.yy.c c.tab.h c.output 2> /dev/null