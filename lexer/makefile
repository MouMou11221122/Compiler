.PHONY:	clean
all: lex.yy.c
	gcc -Wall -o a.out lex.yy.c -lfl
lex.yy.c: midterm.l
	lex midterm.l
clean:
	rm -rf lex.yy.c a.out
