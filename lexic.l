%{
    #include <stdio.h>
    #include<string.h>
    #include "syntSem.tab.h"
    extern YYSTYPE yyval;
    int nb_ligne=1;
    int colonne=0;
%}
%option noyywrap
LOWERCASE [a-z]
chiffre [0-9]
IDF {LOWERCASE}({chiffre}|{LOWERCASE})*("_"({chiffre}|{LOWERCASE})+)*
chiffre_int "-"?{chiffre}+
chiffre_f "-"?{chiffre}+"."{chiffre}+
commentaire1 ([/][*](.|\n)+?[*][/])
commentaire2 [/][/].*
%%
Program {colonne=colonne+ yyleng; return mc_program;}
PDEC {colonne=colonne+ yyleng; return mc_pdec;}
PINST {colonne=colonne+ yyleng; return mc_pinst;}
Begin {colonne=colonne+ yyleng; return mc_begin;}
End {colonne=colonne+yyleng; return mc_end;}
Pint {colonne=colonne+yyleng; return mc_pint;}
Pfloat {colonne=colonne+yyleng;return mc_pfloat;}
@define { colonne=colonne+yyleng; return mc_define;}
FOR {  colonne=colonne+yyleng;return mc_for;}
WHILE {  colonne=colonne+yyleng;return mc_while;}
DO { colonne=colonne+yyleng;return mc_do; }
ENDFOR { colonne=colonne+yyleng;return mc_endfor;}
IF {colonne=colonne+yyleng;return mc_if; nb_ligne++; }
ELSE { colonne=colonne+yyleng;return mc_else;}
ENDIF { colonne=colonne+yyleng;return mc_endif;}
{IDF} {if (yyleng<= 12) {yylval.string=strdup(yytext); return idf;} else {printf("erreur lexical: longeur de l'IDF est plus que 12 caracteres\n");}} 
{chiffre_int} {yylval.integer=atoi(yytext); if((yylval.integer>-32768)&&(yylval.integer<32767)) {colonne=colonne+yyleng;  return chiffre_int; } 
else {printf("Erreur Lexical: le nombre est superieure a 32767 ou inferieur a -32767 a la ligne %d colonne %d\n", nb_ligne,colonne);}}
{chiffre_f} { colonne=colonne+yyleng;yylval.pfloat=atoi(yytext); return chiffre_f; }
";" { colonne++;return ';';}
\= { colonne++;return s_eq;}
"←" {colonne++;return affectation; }
"|" {colonne++;return '|';}
"&" {colonne++;return '&';}
"!" {colonne++;return '!';}
">" {colonne++;return '>';}
"<" { colonne++;return '<';}
"<=" { colonne=colonne+yyleng;return mc_infeq;}
">=" { colonne=colonne+yyleng;return mc_supeq;}
"==" { colonne=colonne+yyleng;return eq;}
"!=" {colonne=colonne+yyleng;return noteq;  }
"+" {colonne++;return '+'; }
"-" {colonne++;return '-'; }
"*" { colonne++;return '*';}
"/" { colonne++;return '/';}
":" { colonne++;return mc_deuxpoints;}
[()] {colonne=colonne+yyleng;return yytext[0];}
{commentaire2} { colonne=0;}
{commentaire1} {
   for(int i = 0; i< strlen(yytext); i++){
      if(yytext[i]=='\n'){
         nb_ligne ++;
         colonne = 0;
      }
      colonne++;
   }
}
[ \t] colonne++;
\n {nb_ligne ++;colonne=0;}
. {printf ("Erreur lexical, a ligne %d colonne %d sur l'entité %s\n",nb_ligne,colonne,yytext);}

%%