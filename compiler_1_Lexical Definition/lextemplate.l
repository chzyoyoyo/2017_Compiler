%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenChar(t)       {LIST; if (Opt_T) printf("<%c>\n", (t));}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, (i));}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, (s));}
#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}

digit  [0-9]
letter [a-zA-Z]
octal  [0-7]

%x COM
%x MENT


%%


"//&S+".*   {
                LIST;
                Opt_S = 1;

            }

"//&S-".*   {
                LIST;
                Opt_S = 0;

            }
"//&T+".*   {
                LIST;
                Opt_T = 1;

            }
"//&T-".*   {
                LIST;
                Opt_T = 0;

            }

"//" { LIST; BEGIN COM;}
"/*" { LIST; BEGIN MENT;}

","         { tokenChar(','); }
";"         { tokenChar(';'); }
":"         { tokenChar(':'); }
"("         { tokenChar('('); }
")"         { tokenChar(')'); }
"["         { tokenChar('['); }
"]"         { tokenChar(']'); }

"+"         { tokenChar('+'); }
"-"         { tokenChar('-'); }
"*"         { tokenChar('*'); }
"/"         { tokenChar('/'); }
"mod"       { token(mod); }
":="        { token(:=); }
"<"         { tokenChar('<'); }
"<="        { token(<=); }
"<>"        { token(<>); }
">="        { token(>=); }
">"         { tokenChar('>'); }
"="         { tokenChar('='); }
"and"       { token(and); }
"or"        { token(or); }
"not"       { token(not); }

"array"     { token(KWarray); }
"begin"     { token(KWbegin); }
"boolean"   { token(KWboolean); }
"def"       { token(KWdef); }
"do"        { token(KWdo); }
"else"      { token(KWelse); }
"end"       { token(KWend); }
"false"     { token(KWfalse); }
"for"       { token(KWfor); }
"integer"   { token(KWinteger); }
"if"        { token(KWif); }
"of"        { token(KWof); }
"print"     { token(KWprint); }
"read"      { token(KWread); }
"real"      { token(KWreal); }
"string"    { token(KWstring); }
"then"      { token(KWthen); }
"to"        { token(KWto); }
"true"      { token(KWtrue); }
"return"    { token(KWreturn); }
"var"       { token(KWvar); }
"while"     { token(KWwhile); }

{letter}({letter}{digit})*              {tokenString(id, yytext);}

0{octal}+                               {tokenString(oct_integer, yytext);}

0|[1-9]{digit}*                         {tokenString(integer, yytext);}

0|[0-9]{digit}*\.{digit}+               {tokenString(float, yytext);}

[0-9]{digit}*(\.{digit}+)?[Ee][+-]?[0-9]{digit}*(\.{digit}+)?  {tokenString(scientific, yytext); }



\"([^\42]|\"\")*\"              {
                                int length = yyleng;
                                int a;
                                int b = 0;
                                char ans[256];
                                memset(ans, 0, 256);
                                for(a = 1; a < length - 1; a++)
                                {
                                    if(yytext[a] == '\"' && yytext[a+1] == '\"' && yytext[a+2] != '\"')
                                    {
                                        continue;
                                    }
                                    else
                                    {
                                        ans[b] = yytext[a];
                                        b++;
                                    }

                                }
                                tokenString(string,ans);

                                for(a = 0; a < 256; a++)
                                {
                                    ans[a] = '\0';
                                }

                            }


[ \t]   { LIST; }





\n      {
          
          if (Opt_S)
            printf("%d: %s\n", linenum, buf);
          linenum++;
          buf[0] = '\0';
        }







<COM>.      {LIST;} 
<COM>\n     {
                
                if (Opt_S)
                printf("%d: %s\n", linenum, buf);
                linenum++;
                buf[0] = '\0';
                BEGIN INITIAL; 
            }


<MENT>.     {LIST; }  
<MENT>\n    {
                
                if (Opt_S)
                printf("%d: %s\n", linenum, buf);
                linenum++;
                buf[0] = '\0';
            }
<MENT>\*\/  {LIST; BEGIN INITIAL; }

.           {
                /* error */
                printf("error: line %d, bad character \" %s \"\n", linenum, yytext );
                exit(-1);
            }



%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}
