%{
#include <stdio.h>
#include"semantique.h"
extern int nb_ligne;
extern int colonne;
int yyparse();
int yylex();
int yyerror(char *s);
int typeidf;
float chiffre_idf;

%}
%union{
    int integer;
    float pfloat;
    char* string;
}
%start S

%token mc_program mc_pdec mc_pinst mc_begin mc_endif mc_pint 
%token mc_pfloat mc_define mc_end
%token mc_deuxpoints mc_for mc_while mc_do mc_endfor mc_if mc_else 
%token '(' ')' '=' ',' ';' 
%token  affectation  s_eq  

%left '|'
%left '&'
%left '!'
%left '<' '>' mc_supeq mc_infeq eq noteq
%left '+' '-'
%left '*' '/'

%token <string>idf 
%token <integer> chiffre_int
%token <pfloat> chiffre_f
%%

S: entete mc_pdec dec mc_pinst mc_begin partieInstruction mc_end 
{ printf ("programme syntaxiquement juste\n"); afficher(); }
;
entete: mc_program  idf
;
dec:  decc dec
    | decc 
    | decv dec 
    | decv 
;
decv: params mc_deuxpoints type ';' 
 {   while(list2!=NULL){ 
      insertion(list2->name,typeidf,0); // l'insertion est faite dans "params"
      list2=list2->suivant; 
     }
       }
decc:mc_define mc_pint idf s_eq chiffre ';' 
    {if(non_declarer($3) ==0){insertion($3, 0, 1);}
    else{
        printf("Erreur Semantique: Double declaration de %s dans la ligne %d et la colonne %d\n",$3, nb_ligne,colonne);
    }
    //char ch[10]; itoa(chiffre_idf,ch,10);  insererVal($3,ch);
    } |
    mc_define mc_pfloat idf s_eq chiffre ';' 
    {if(non_declarer($3) ==0){insertion($3, 1, 1);}
    else{
        printf("Erreur Semantique: Double declaration de %s dans la ligne %d et la colonne %d\n",$3, nb_ligne,colonne);
    }
    //char ch[10]; itoa(chiffre_idf,ch,10);  insererVal($3,ch);
    }
;

type: mc_pint{typeidf=0;// typeidf est utilisé pour sauvgarder le type de la var
}
    | mc_pfloat{typeidf=1;}
;

params: params '|' idf   { 
    if(non_declarer($3)==0){
     insererparam($3);//insertion dans la liste des params    
     }  
    else{
        printf("Erreur Semantique: Double declaration de %s dans la ligne %d et la colonne %d\n",$3, nb_ligne,colonne);
    }
     }
    | idf {if(non_declarer($1)==0){
    insererparam($1);    }
    else{
        printf("Erreur Semantique: Double Declaration de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }
     }
;

partieInstruction: inst partieInstruction 
    | inst
;
inst : aff ';'
    |boucle 
    | condition
;
aff: idf affectation idf {
    if(non_declarer($1)==0 || non_declarer($3)==0){
        
        printf("Erreur Semantique: Non Declaree de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    
    }else{
    if(modification_cst($1)==0){
            printf("Erreur Semantique: Modification d'une constante de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }else{
        if(incompatible_type(getType($1), getType($3)) == 0){
            printf("Erreur Semantique: Incompatible Type de %s et %s dans la ligne %d et la colonne %d \n",$1,$3,nb_ligne,colonne);
            
        }
        
    }
    }    
}
| idf affectation chiffre_f 
{
    if(non_declarer($1)==0 ){
        
        printf("Erreur Semantique: Variable Non Declarer %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    
    }else{
    if(modification_cst($1)==0){
            printf("Erreur Semantique: Modification d'une constante de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }else{
        if(incompatible_type(getType($1), 1) == 0){
            printf("Erreur Semantique: Incompatible Type de %s et %s dans la ligne %d et la colonne %d \n",$1,$3,nb_ligne,colonne);
            
        }
    }
    }    
}
| idf affectation chiffre_int 
{
    if(non_declarer($1)==0 ){
        
        printf("Erreur Semantique: Variable Non Declarer %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    
    }else{
    if(modification_cst($1)==0){
            printf("Erreur Semantique: Modification d'une constante de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }else{
        if(incompatible_type(getType($1),0) == 0){
            printf("Erreur Semantique: Incompatible Type de %s et %s dans la ligne %d et la colonne %d \n",$1,$3,nb_ligne,colonne);
            
        }
    }
    }    
}
| idf affectation expression_arithemtique { 
    if (non_declarer($1)==0) {
        printf("Erreur Semantique: Varibale Non Declaree %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }
    else{
        if(modification_cst($1)==0){
            printf("Erreur Semantique: Modification d'une constante de %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
        }
        
        }
    }
;

chiffre:chiffre_int {chiffre_idf= $1;}
| chiffre_f	{chiffre_idf= $1;}			
;
boucle: mc_for aff mc_while value mc_do partieInstruction mc_endfor
;

condition: mc_do partieInstruction mc_if mc_deuxpoints'(' logs ')' mc_else partieInstruction mc_endif
;
logs: log | log logs
;
log: '('val')' '|' '('val')' 
    | '('val ')''&' '('val ')'
    | cnd 
    | '!' '('logs')'
;
val: cnd 
    |idf {if (non_declarer($1)==0) {
        printf("Erreur Semantique: Varibale Non Declaree %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    } }
;
cnd: value mc_supeq value 
    |value '<' value
    |value '>' value
    |value mc_infeq value
    |value eq value
    |value noteq value
;
value: idf {if (non_declarer($1)==0) {
        printf("Erreur Semantique: Varibale Non Declaree %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }
    }
    |chiffre
;
expression_arithemtique: expression_arithemtique '+' idf_chiffre |idf_chiffre '+' idf_chiffre
                        |expression_arithemtique '-' idf_chiffre |idf_chiffre '-' idf_chiffre 
                        |expression_arithemtique '*' idf_chiffre |idf_chiffre '*' idf_chiffre 
                        |expression_arithemtique '/' idf_chiffre {if(chiffre_idf== 0){printf("Erreur Semantique: Division par zero dans la ligne %d et la colonne %d \n",nb_ligne,colonne);}}
                         |idf_chiffre '/' idf_chiffre{if(chiffre_idf== 0){printf("Erreur Semantique: Division par zero dans la ligne %d et la colonne %d \n",nb_ligne,colonne);}}
;
idf_chiffre: idf { 
    if (non_declarer($1)==0) {
        printf("Erreur Semantique: Varibale Non Declarée %s dans la ligne %d et la colonne %d \n",$1,nb_ligne,colonne);
    }
    }
        |chiffre
;

%%
int yyerror(char* msg)
{printf("Erreur Syntaxique a la ligne %d et colonne %d: \n",nb_ligne,colonne);
return 0;
}

int main()  {   

yyparse(); 

return 0;  
}
        