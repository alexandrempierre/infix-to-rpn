CC=g++ -Wall

all: infix_to_rpn.out

lex.yy.c: infix_to_rpn.l
	lex infix_to_rpn.l

infix_to_rpn.out: lex.yy.c 
	$(CC) lex.yy.c -ll -o infix_to_rpn.out

remove:
	rm infix_to_rpn.out
	rm lex.yy.c