%{
    /* ????? */
    #include <stdio.h>
    void yyerror(char *);
%}


comment_line                    ([^\n]*{new_line})
comment                         \/\/{comment_line}|\/\*[^(\*\/)]*\*\/
letter							[a-zA-Z]
new_line                        \n
non_zero_digit					[1-9]
digit							0|{non_zero_digit}
any_char						{letter}|{digit}|[" "]|{symbols}
str                             ({any_char})*
variable_str                    ({letter}|{digit})*
angle_literal                   (1{digit}{digit}|2{digit}{digit}|3{digit}{digit}|{non_zero_digit}{digit}|{digit})
string_literal                  \"{str}\"
char_literal                    \'{any_char}\'
integer_literal                 {digit}+
float_literal                   {integer_literal}\.{integer_literal}|\.{integer_literal}|{integer_literal}
literal                         ({integer_literal}|{float_literal}|{char_literal}|{bool_literal}|{angle_literal})
identifier                      int|float|char|string|bool|angle
variable                        {letter}{variable_str}|{letter}{variable_str}\[{integer_literal}\]|{letter}{variable_str}\[{angle_literal}\]|{letter}{variable_str}\[{letter}{variable_str}\]
bool_literal			        true|false
symbols                         \(|\)|\{|\}|\[|\]|\<|\>|\&|\||\^|\+|\-|\?|\*|\/|\_|\=|\,|\:|\.

%option                         yylineno
%%

INIT                            return(INIT);
FINISH                          return(FINISH);
{comment}			            return(COMMENT);
for                             return(FOR);
while				            return(WHILE);
in                              return(IN);
if				                return(IF);
elif                            return(ELIF);
else				            return(ELSE);
send  				            return(SEND);
recieve				            return(RECIEVE);
return				            return(RETURN);
getHeading                      return(GETH);
getAltitude                     return(GETA);
getTemperature                  return(GETT);
vertical                        return(VERTICAL);
horizontal                      return(HORIZONTAL);
turn                            return(TURN);
spray                           return(SPRAY);
connect                         return(CONNECT);
and|\&\&				        return(AND);
or|\|\|			                return(OR);
[+|-]?{angle_literal}           return(ANGLE_LITERAL);
[+|-]?{integer_literal}	        return(INTEGER_LITERAL);
{bool_literal}			        return(BOOL_LITERAL);
[+|-]?{float_literal}		    return(FLOATING_POINT_LITERAL);
{char_literal}			        return(CHAR_LITERAL);
{string_literal}		        return(STRING_LITERAL);
int 				            return(IDENTIFIER_INT);
float 				            return(IDENTIFIER_FLOAT);
string				            return(IDENTIFIER_STRING);
char				            return(IDENTIFIER_CHAR);
bool				            return(IDENTIFIER_BOOL);
angle                           return(IDENTIFIER_ANGLE);
{variable}			            return(VARIABLE);
\(				                return(LEFT_PARANTHESIS);
\)                              return(RIGHT_PARANTHESIS);
\{				                return(LEFT_CURLY_BRACKET);
\}				                return(RIGHT_CURLY_BRACKET);
\[				                return(LEFT_SQUARE_BRACKET);
\]				                return(RIGHT_SQUARE_BRACKET);
\.				                return(DOT);
\&				                return(AND_BITWISE);
\^				                return(XOR_BITWISE);
\=\=				            return(EQUALITY_CHECK_OPERATOR);
\!\=				            return(INEQUALITY_CHECK_OPERATOR);
\<\=				            return(LESS_THAN_OR_EQUAL_OPERATOR);
\>\=				            return(GREATER_THAN_OR_EQUAL_OPERATOR);
\+\=                            return(PLUS_EQUALS_OPERATOR);
\-\=                            return(MINUS_EQUALS_OPERATOR);
\*\=                            return(MULTIPLE_EQUALS_OPERATOR);
\/\=                            return(DIVIDE_EQUALS_OPERATOR);
\&\=                            return(AND_BITWISE_EQUALS_OPERATOR);
\^\=                            return(XOR_BITWISE_EQUALS_OPERATOR);
\|\=                            return(OR_BITWISE_EQUALS_OPERATOR);
\+\+                            return(PLUS_ONE_OPERATOR);
\-\-                            return(MINUS_ONE_OPERATOR);
\<				                return(LESS_THAN_OPERATOR);
\>				                return(GREATER_THAN_OPERATOR);
\=				                return(ASSIGNMENT_OPERATOR);
\+				                return(PLUS_OPERATOR);
\-				                return(MINUS_OPERATOR);
\*				                return(MULTIPLY_OPERATOR);
\/				                return(DIVISION_OPERATOR);
\%                              return(MODULO_OPERATOR);
\!                              return(NEGATION_OPERATOR);
\~                              return(TILDE_OPERATOR);
\>\>                            return(SHIFT_RIGHT_OPERATOR);
\<\<                            return(SHIFT_LEFT_OPERATOR);
\+\>                            return(TURN_CW);
\+\<                            return(TURN_CCW);
\|                              return(OR_BITWISE);
\;				                return(SEMICOLON);
\:				                return(COLON);
\,				                return(COMMA);
\_                              return(UNDERSCORE);
\?                              return(QUESTION_MARK);
\n                              ;
.                               ;

%%


int yywrap(void) { return 1; }
