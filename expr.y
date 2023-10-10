%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC 文件
**********************************************/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif

int yylex();
extern int yyparse();
FILE *yyin;
void yyerror(const char *s);
%}

// TODO: 给每个符号定义一个单词类别
%token ADD    // 加号
%token MINUS  // 减号
%token MULTIPLY  // 乘号
%token DIVIDE  // 除号
%token LPAREN  // 左括号
%token RPAREN  // 右括号
%token NUMBER  // 数字

//left，right明确结合性
//定义了算术运算符的优先级，越靠下优先级越高。`UMINUS`用于识别负数。
%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS

//语法分析段
%%

lines : lines expr ';' { printf("%f\n", $2); }
      | lines ';'
      |
      ;
// TODO: 完善表达式的规则
// $$代表产生式左部的属性值，$n 为产生式右部第n个token的属性值
expr : expr ADD expr { $$ = $1 + $3; }
     | expr MINUS expr { $$ = $1 - $3; }
     | expr MULTIPLY expr { $$ = $1 * $3; }
     | expr DIVIDE expr { $$ = $1 / $3; }
     | MINUS expr %prec UMINUS { $$ = -$2; }   //%prec UMINUS声明表示一元减号的优先级高于其他运算符，因此在表达式中会首先计算一元减号
     | NUMBER { $$ = $1; }
     | LPAREN expr RPAREN { $$ = $2; }
     ;


%%


// 程序部分
//词法分析段

int yylex()
{
    int t; //储存字符
    while (1)
    {
        t = getchar(); // 从输入流中获取下一个字符
        if (t == ' ' || t == '\t' || t == '\n')
        {
            // 忽略空白字符、制表符和换行符
        }
        else if (isdigit(t))
        {
            // TODO: 解析多位数字返回数字类型
            // 如果当前字符是数字
            ungetc(t, stdin); // 将第一个数字字符放回输入流
            int value = 0;
            while (isdigit(t = getchar()))
            {
                value = value * 10 + (t - '0'); // 解析多位整数
            }
            ungetc(t, stdin); // 将非数字字符放回输入流
            yylval = value;   // 存储解析的整数值
            return NUMBER;    // 返回标记值为NUMBER的标记
        }
        else if (t == '+')
        {
            return ADD; 
        }
        else if (t == '-')
        {
            return MINUS; 
        }
        else if (t == '*')
        {
            return MULTIPLY; 
        }
        else if (t == '/')
        {
            return DIVIDE; 
        }
        else if (t == '(')
        {
            return LPAREN;
        }
        else if (t == ')')
        {
            return RPAREN;
        }
        else
        {
            return t; // 返回未知字符的标记（将字符本身作为标记）
        }
    }
}

/*
yylex函数笔记：
yylex使用一个无限循环来连续读取字符，直到识别到一个有效的词法单元（token）为止。
首先，它使用 getchar 从输入流中获取下一个字符，并存储在变量 t 中。
如果字符是空格、制表符或换行符，则忽略它们，不返回任何标记。
如果字符是数字（isdigit(t) 返回 true），则进入一个循环，解析多位整数，并将整数值存储在 yylval 变量中。然后，返回一个标记为 NUMBER 的标记，表示识别到一个整数。
如果字符是加号、减号、乘号、除号、左括号或右括号，则分别返回相应的标记（ADD、MINUS、MULTIPLY、DIVIDE、LPAREN、RPAREN）。
如果字符不属于上述任何一种情况，则将字符本身作为标记值返回，表示未知字符。
在每次循环迭代中，yylex 函数从输入流中读取字符，直到识别到一个有效的标记为止，然后返回该标记。
*/

int main(void)
{
    yyin = stdin;
    do
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "解析错误: %s\n", s);
    exit(1);
}
