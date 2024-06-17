.PHONY: clean

CC			= gcc
LEX			= lex
YACC		= yacc
CFLAGS		= -Wall -c 
LIBS		= -ly -lfl
EXEC		= compiler
OBJS		= parser.o	\
			  scanner.o
				
all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) -o $@ $^ $(LIBS)

parser.o: parser.c compiler.h
	$(CC) $(CFLAGS) -o $@ $<

scanner.o: scanner.c compiler.h parser.h
	$(CC) $(CFLAGS) -o $@ $<

parser.c: parser.y
	$(YACC) -d -o $@ $<	

scanner.c: scanner.l
	$(LEX) -o $@ $<

clean:
	rm -rf $(EXEC) scanner.c parser.c parser.h *.o 




