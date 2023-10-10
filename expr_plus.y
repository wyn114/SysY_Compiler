%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 )、标识符、赋值符号和整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC 文件
**********************************************/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

// #ifndef YYSTYPE
// #define YYSTYPE double
// #endif

// 符号表结构
struct symbol_entry {
    char name[100];
    double value;
};

struct symbol_table_ {
    struct symbol_entry entries[100];
    int count;
};

struct symbol_table_ symbol_table;

int yylex();
extern int yyparse();
FILE *yyin;
void yyerror(const char *s);

double getValue(char* id)
{
    //printf("89%s\n",id);
    int i;
    //printf("%d\n", symbol_table.count);
    for (i = 0; i < symbol_table.count; i++) 
    {
        // printf("%s\n",symbol_table.entries[i].name);
        // printf("%s\n",id);
        // int p;
        // p=strcmp(id, symbol_table.entries[i].name);
        // printf("%d\n",p);
        if (strcmp(id, symbol_table.entries[i].name) == 0)
        {
            
            //printf("return\n");
            return(symbol_table.entries[i].value);
        }
    }
    return 0.0;
}

void addSymbol(char* id, double value)
{
    // 在符号表中查找变量，如果不存在则添加
    int i;
    for (i = 0; i < symbol_table.count; i++) 
    {
        if (strcmp(id, symbol_table.entries[i].name) == 0) 
        {
            symbol_table.entries[i].value = value;
            break;
        }
    }
    if (i == symbol_table.count) {
        strcpy(symbol_table.entries[symbol_table.count].name, id);
        int a;
        a=strcmp(id, symbol_table.entries[symbol_table.count].name);
        //printf("%d\n",a);
        symbol_table.entries[symbol_table.count].value = value;
        symbol_table.count++;
    }
}

%}

%union
{
    char* id;
    double num;
}

// TODO: 给每个符号定义一个单词类别
%token ADD    // 加号
%token MINUS  // 减号
%token MULTIPLY  // 乘号
%token DIVIDE  // 除号
%token LPAREN  // 左括号
%token RPAREN  // 右括号
%token <num> NUMBER  // 数字
%token <id> ID  // 标识符
%token ASSIGN  // 赋值符号

%type <num> statement
%type <num> expr

//left,right明确结合性
//定义了算术运算符的优先级，越靠下优先级越高。`UMINUS`用于识别负数。
%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS

//语法分析段
%%

lines : lines expr ';' { printf("%f\n", $2); }
      | lines statement ';' 
      | lines ';'
      |
      ;

// 语句可以是赋值语句或表达式
statement : ID ASSIGN expr { addSymbol($1, $3); $$ = $3;}
          ;

// TODO: 完善表达式的规则
// $$代表产生式左部的属性值，$n 为产生式右部第n个token的属性值
expr : expr ADD expr { $$ = $1 + $3; }
     | expr MINUS expr { $$ = $1 - $3; }
     | expr MULTIPLY expr { $$ = $1 * $3; }
     | expr DIVIDE expr { $$ = $1 / $3; }
     | MINUS expr %prec UMINUS { $$ = -$2; }   //%prec UMINUS声明表示一元减号的优先级高于其他运算符，因此在表达式中会首先计算一元减号
     | NUMBER { $$ = $1; }
     | ID { char* tmp = malloc(50*sizeof(char));strcpy(tmp, $1);$$ = getValue(tmp); }
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
        else if (t == '=')
        {
            return ASSIGN; // 返回标记值为ASSIGN的标记
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
            yylval.num = value;   // 存储解析的整数值
            return NUMBER;    // 返回标记值为NUMBER的标记
        }
        else if (isalpha(t))
        {
            // TODO: 解析标识符
            ungetc(t, stdin); // 将第一个字符放回输入流
            char id[256];
            int i = 0;
            while (isalnum(t = getchar()) || t == '_')
            {
                if (i < 255)
                {
                    id[i++] = t;
                }
                else
                {
                    fprintf(stderr, "标识符过长\n");
                    exit(1);
                }
            }
            ungetc(t, stdin);
            if (i == 0)
            {
                fprintf(stderr, "无效标识符\n");
                exit(1);
            }
            id[i] = '\0';
            yylval.id=id; // 存储解析的标识符
            return ID;         // 返回标记值为ID的标记
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

/*
yylex函数笔记：

*/
int main(void)
{
    yyin = stdin;
    symbol_table.count = 0; // 初始化符号表计数器
    do{
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "解析错误: %s\n", s);
    exit(1);
}
