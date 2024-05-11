all: c

yacc: c.tab.c c.tab.h

c.tab.c c.tab.h: c.y
	bison -Wcounterexamples -t -v -d c.y

lex.yy.c: c.l c.tab.h
	flex c.l

c: lex.yy.c c.tab.c c.tab.h manip.c manip.h
	gcc -o c c.tab.c lex.yy.c manip.c

test: all test1.c interpreter.py
	./c < test1.c
	python3 interpreter.py
	

clean:
	rm c c.tab.c asm.txt lex.yy.c c.tab.h c.s c.output 2> /dev/null

counter: c.y
	bison -t -v -d -Wcounterexamples c.y
