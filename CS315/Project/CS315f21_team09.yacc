
%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex(void);
    void yyerror(char* s);
    extern int yylineno;
%}

%token                          INIT
%token                          FINISH
%token                          COMMENT
%token                          FOR
%token                          WHILE
%token                          IN
%token                          IF
%token                          ELIF
%token                          ELSE
%token                          SEND
%token                          RECIEVE
%token                          RETURN
%token                          AND
%token                          OR
%token                          ANGLE_LITERAL
%token                          INTEGER_LITERAL
%token                          BOOL_LITERAL
%token                          FLOATING_POINT_LITERAL
%token                          CHAR_LITERAL
%token                          STRING_LITERAL
%token                          IDENTIFIER_INT
%token                          IDENTIFIER_FLOAT
%token                          IDENTIFIER_STRING
%token                          IDENTIFIER_CHAR
%token                          IDENTIFIER_BOOL
%token                          IDENTIFIER_ANGLE
%token                          VARIABLE
%token                          LEFT_PARANTHESIS
%token                          RIGHT_PARANTHESIS
%token                          LEFT_CURLY_BRACKET
%token                          RIGHT_CURLY_BRACKET
%token                          LEFT_SQUARE_BRACKET
%token                          RIGHT_SQUARE_BRACKET
%token                          DOT
%token                          AND_BITWISE
%token                          XOR_BITWISE
%token                          EQUALITY_CHECK_OPERATOR
%token                          INEQUALITY_CHECK_OPERATOR
%token                          LESS_THAN_OR_EQUAL_OPERATOR
%token                          GREATER_THAN_OR_EQUAL_OPERATOR
%token                          PLUS_EQUALS_OPERATOR
%token                          MINUS_EQUALS_OPERATOR
%token                          MULTIPLE_EQUALS_OPERATOR
%token                          DIVIDE_EQUALS_OPERATOR
%token                          AND_BITWISE_EQUALS_OPERATOR
%token                          XOR_BITWISE_EQUALS_OPERATOR
%token                          OR_BITWISE_EQUALS_OPERATOR
%token                          PLUS_ONE_OPERATOR
%token                          MINUS_ONE_OPERATOR
%token                          LESS_THAN_OPERATOR
%token                          GREATER_THAN_OPERATOR
%token                          ASSIGNMENT_OPERATOR
%token                          PLUS_OPERATOR
%token                          MINUS_OPERATOR
%token                          MULTIPLY_OPERATOR
%token                          DIVISION_OPERATOR
%token                          MODULO_OPERATOR
%token                          NEGATION_OPERATOR
%token                          TILDE_OPERATOR
%token                          SHIFT_RIGHT_OPERATOR
%token                          SHIFT_LEFT_OPERATOR
%token                          TURN_CW
%token                          TURN_CCW
%token                          OR_BITWISE
%token                          SEMICOLON
%token                          COLON
%token                          COMMA
%token                          UNDERSCORE
%token                          QUESTION_MARK
%token                          NEWLINE
%token                          GETH
%token                          GETA
%token                          GETT
%token                          VERTICAL
%token                          HORIZONTAL
%token                          TURN
%token                          SPRAY
%token                          CONNECT
%token                          EMBEDDED_PARAMETER

%start                          program


%%

program                     : INIT statements FINISH
                            ;
statements                  : statement
                            | statement statements
                            | COMMENT statements
                            ;
statement                   : declaration_statement
                            | operation_statement SEMICOLON
                            | receive_statement SEMICOLON
                            | send_statement SEMICOLON
                            | if_statement
                            | loop_statement
                            | call_statement SEMICOLON
                            ;
declaration_statement       : variable_declaration  SEMICOLON
                            | function_declaration
                            ;
operation_statement         : variable_declaration assignment_operator expression
                            | VARIABLE  assignment_operator expression
                            | primary_expression PLUS_ONE_OPERATOR
                            | primary_expression MINUS_ONE_OPERATOR
                            | primary_expression TURN_CW
                            | primary_expression TURN_CCW
                            ;
receive_statement           : RECIEVE scan
                            ;
scan                        : VARIABLE
                            | scan PLUS_OPERATOR VARIABLE
                            ;
send_statement              : SEND print
                            ;
print                       : print_content
                            | print PLUS_OPERATOR print_content
                            ;
print_content               : VARIABLE
                            | STRING_LITERAL
                            ;
if_statement                : IF LEFT_PARANTHESIS expression RIGHT_PARANTHESIS block elif_statement
                            | IF LEFT_PARANTHESIS expression RIGHT_PARANTHESIS block elif_statement ELSE block
                            ;
elif_statement              : elif_statement ELIF LEFT_PARANTHESIS expression RIGHT_PARANTHESIS block 
                            | /* empty */
                            ;
loop_statement              : for_statement
                            | while_statement
                            ;
call_statement              : function_call
                            | embedded_function
                            ;
function_call               : VARIABLE LEFT_PARANTHESIS parameters RIGHT_PARANTHESIS 
                            ;
variable_declaration        : identifier VARIABLE
                            ;
block                       : LEFT_CURLY_BRACKET statements RIGHT_CURLY_BRACKET
                            | LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET
                            | expressions SEMICOLON
                            ;
function_declaration        : variable_declaration LEFT_PARANTHESIS declaration_parameters RIGHT_PARANTHESIS LEFT_CURLY_BRACKET statements RETURN expression SEMICOLON RIGHT_CURLY_BRACKET
                            ;
declaration_parameters      : variable_declaration COMMA declaration_parameters
                            | variable_declaration
                            | /* empty */
                            ;
parameters                  : parameter COMMA parameters
                            | parameter
                            | /* empty */
                            ;
parameter                   : literal
                            | call_statement
                            | VARIABLE
                            ;
embedded_function           : GETH LEFT_PARANTHESIS RIGHT_PARANTHESIS
                            | GETA LEFT_PARANTHESIS RIGHT_PARANTHESIS
                            | GETT LEFT_PARANTHESIS RIGHT_PARANTHESIS
                            | VERTICAL LEFT_PARANTHESIS numerical_parameter RIGHT_PARANTHESIS
                            | HORIZONTAL LEFT_PARANTHESIS numerical_parameter RIGHT_PARANTHESIS
                            | TURN LEFT_PARANTHESIS bool_parameter RIGHT_PARANTHESIS
                            | SPRAY LEFT_PARANTHESIS bool_parameter RIGHT_PARANTHESIS
                            | CONNECT LEFT_PARANTHESIS bool_parameter RIGHT_PARANTHESIS
                            ;

numerical_parameter         : INTEGER_LITERAL | FLOATING_POINT_LITERAL | ANGLE_LITERAL | VARIABLE ;

bool_parameter              : BOOL_LITERAL | VARIABLE ;

while_statement             : WHILE LEFT_PARANTHESIS expression RIGHT_PARANTHESIS block
                            ;
for_statement               : FOR LEFT_PARANTHESIS VARIABLE IN VARIABLE RIGHT_PARANTHESIS block
                            | FOR LEFT_PARANTHESIS variable_declaration IN VARIABLE RIGHT_PARANTHESIS block
                            | FOR LEFT_PARANTHESIS for_ops  SEMICOLON expressions  SEMICOLON for_ops RIGHT_PARANTHESIS block
                            ;
for_ops                     : operation_statement
                            | for_ops COMMA operation_statement
                            | /* empty */
                            ;
expressions                 : expression
                            | expressions COMMA expression
                            | /* empty */
                            ;
expression                  : qm_expression
                            ;
qm_expression               : logic_expression
                            | logic_expression QUESTION_MARK expression COLON qm_expression
                            ;
logic_expression            : bitwise_expression
                            | logic_expression AND bitwise_expression
                            | logic_expression OR bitwise_expression
                            ;
bitwise_expression          : equality_expression
                            | bitwise_expression XOR_BITWISE equality_expression
                            | bitwise_expression AND_BITWISE equality_expression
                            ;
equality_expression         : relational_expression
                            | equality_expression EQUALITY_CHECK_OPERATOR relational_expression
                            | equality_expression INEQUALITY_CHECK_OPERATOR relational_expression
                            ;
relational_expression       : shift_expression
                            | relational_expression LESS_THAN_OPERATOR shift_expression
                            | relational_expression GREATER_THAN_OPERATOR shift_expression
                            | relational_expression LESS_THAN_OR_EQUAL_OPERATOR shift_expression
                            | relational_expression GREATER_THAN_OR_EQUAL_OPERATOR shift_expression
                            ;
shift_expression            : additive_expression
                            | shift_expression SHIFT_RIGHT_OPERATOR additive_expression
                            | shift_expression SHIFT_LEFT_OPERATOR additive_expression
                            ;
additive_expression         : multiplicative_expression
                            | additive_expression PLUS_OPERATOR multiplicative_expression
                            | additive_expression MINUS_OPERATOR multiplicative_expression
                            ;
multiplicative_expression   : cast_expression
                            | multiplicative_expression MULTIPLY_OPERATOR cast_expression
                            | multiplicative_expression DIVISION_OPERATOR cast_expression
                            | multiplicative_expression MODULO_OPERATOR cast_expression
                            ;
cast_expression             : unary_expression
                            | LEFT_PARANTHESIS identifier RIGHT_PARANTHESIS cast_expression
                            ;
unary_expression            : postfix_expression
                            | NEGATION_OPERATOR postfix_expression
                            | TILDE_OPERATOR postfix_expression
                            | MINUS_OPERATOR postfix_expression
                            | PLUS_OPERATOR postfix_expression
                            ;
postfix_expression          : primary_expression
                            | primary_expression PLUS_ONE_OPERATOR
                            | primary_expression MINUS_ONE_OPERATOR
                            | primary_expression TURN_CW
                            | primary_expression TURN_CCW
                            ;
primary_expression          : literal
                            | call_statement
                            | LEFT_PARANTHESIS expression RIGHT_PARANTHESIS
                            | VARIABLE
                            ;
identifier                  : IDENTIFIER_INT
                            | IDENTIFIER_FLOAT
                            | IDENTIFIER_CHAR
                            | IDENTIFIER_STRING
                            | IDENTIFIER_BOOL
                            | IDENTIFIER_ANGLE
                            ;
literal                     : INTEGER_LITERAL
                            | FLOATING_POINT_LITERAL
                            | CHAR_LITERAL
                            | STRING_LITERAL
                            | BOOL_LITERAL
                            | ANGLE_LITERAL
                            ;
assignment_operator         : ASSIGNMENT_OPERATOR
                            | PLUS_EQUALS_OPERATOR
                            | MINUS_EQUALS_OPERATOR
                            | MULTIPLE_EQUALS_OPERATOR
                            | DIVIDE_EQUALS_OPERATOR
                            | XOR_BITWISE_EQUALS_OPERATOR
                            | AND_BITWISE_EQUALS_OPERATOR
                            | OR_BITWISE_EQUALS_OPERATOR
                            ;


%%

#include "lex.yy.c"

void yyerror(char *s) { 
    printf( "%s on line %d!\n", s, yylineno );
}

int main(void){ 
    int result = yyparse();
    if (result == 0){
        printf( "Input program is valid!\n" );
    }
}
