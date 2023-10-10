.PHONY: expr1,test,state

expr:
	yacc expr.y -o expr.tab.c
	gcc expr.tab.c -o compute_expr
	./compute_expr
state:
	yacc state.y -o state.tab.c
	gcc state.tab.c -o compute_state
	./compute_state
test:
	yacc expr_plus.y -o expr_plus.tab.c
	gcc expr_plus.tab.c -o compute_expr_plus
	./compute_expr_plus