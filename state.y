%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC 文件
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#ifndef YYSTYPE // 由于需要返回的是一个后缀表达式，是一个字符串，因此 YYSTYPE可声明为 char*
#define YYSTYPE char* // 用于确定$$的变量类型
#endif

char idStr[50];
char numStr[50];
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
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

// 语法分析段
%%

lines :    lines expr ';' { printf("%s\n", $2); } 
      |    lines ';'
      |
      ;
// TODO：将计算值修改成字符串的拷贝（strcpy）和连接（strcat）
expr  :    expr ADD expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"+"); }
      |    expr MINUS expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"- "); }
      |    expr MULTIPLY expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"* "); }
      |    expr DIVIDE expr  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"/ "); }
      |    LPAREN expr RPAREN   { $$ = $2; }
      |    MINUS  expr %prec UMINUS  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,"- "); strcat($$,$2); }
      |    NUMBER         { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$," "); }
      ;

%%

// 程序部分
// 词法分析段

int yylex()
{
    int t; //储存字符
    while(1)
    {
        t=getchar(); // 从输入流中获取下一个字符
        if(t == ' ' || t == '\t' || t == '\n')
            ;
        
        else if ((t>='0' && t<= '9')){
            int n=0;
            // 当读到一个字符为整数字符时，连续接下来的数字字符直到读到的不为数字字符的字符
            while((t>='0'&&t<='9')){
                numStr[n]=t;
                t=getchar();
                n++;
            }
            // 在字符串最后添加结束符\0
            numStr[n]='\0';
            // 将这个字符串的地址赋给yylval
            yylval=numStr;
            ungetc(t,stdin);
            return NUMBER;
        }
        
        else if (t == '+')
        {
            return ADD; // 返回标记值为ADD的标记
        }
        else if (t == '-')
        {
            return MINUS; // 返回标记值为MINUS的标记
        }
        else if (t == '*')
        {
            return MULTIPLY; // 返回标记值为MULTIPLY的标记
        }
        else if (t == '/')
        {
            return DIVIDE; // 返回标记值为DIVIDE的标记
        }
        else if (t == '(')
        {
            return LPAREN; // 返回标记值为LPAREN的标记
        }
        else if (t == ')')
        {
            return RPAREN; // 返回标记值为RPAREN的标记
        }
        else
        {
            return t; // 返回未知字符的标记（将字符本身作为标记）
        }
    }
}

int main(void)
{
    yyin = stdin;
    do
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}
void yyerror(const char* s)
{
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}