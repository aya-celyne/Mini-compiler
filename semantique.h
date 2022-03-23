#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//? Déclatarion de la structure du l'element de la table de symbole
    typedef struct element *TS;
    typedef struct element{
        char nom[20];
        int type; //! 0=intgr , 1=float
        int nature; //! 0=var , 1=cst 
        char value[20];
        TS suivant;
    }element;

//Initialisation de la table des symboles
TS TableSymbole=NULL;  // la tete de la liste
//! --------------- Les fonctions basic de la TS ---------------------
    //* Recherche d'une variable dans la table des symboles
    TS Recherche(char n[]){
        
        TS p = TableSymbole;
        while (p !=NULL && strcmp(p->nom,n)!=0){  p= p->suivant; }
        return p;
    }
    //* Insertion dans la table des symboles
    
    int insertion(char name[20],int type,int nature){
       
        TS nv;
        if (Recherche(name) == NULL)
        {   
            nv = (TS) malloc(sizeof (element));
            nv->type=type;
            nv->nature=nature;
            strcpy(nv->nom,name);
            nv->suivant=TableSymbole;
            TableSymbole=nv;
                       
            printf("%s %d %d\n", nv->nom,nv->type,nv->nature);
            return 1;
        }
        else {
            printf("insertion non effectuer");
            return 0;
        } 
    }
    //dans la declaration d'une variable ou d'une cst
    //apres avoir virifier si la var n'est pas declaré au paravant


    //*Affichage de la table des symboles
    void afficher(){
        printf("La table des symboles:\n");
        printf("_________________________________________________\n");
        printf("\t| Type   | Nature   | Nom de la Variable |\n");
        printf("_________________________________________________\n");
        TS l=TableSymbole;
        while(l !=NULL){
            if(l->type==0) printf("\t| Integer ");
            else if(l->type==1) printf("\t| Float   ");
            if(l->nature==0) printf("| Variable ");
            else if(l->nature==1) printf("| Constant ");
            printf("| %s\n",l->nom);
            printf("_________________________________________________\n");
            l= l->suivant;
        }
    }

    //* Insertion de la valeur de notre variable ou constant
    void insererVal(char entite[],char val[]){
        TS p = Recherche(entite);
        strcpy(p->value,val);
    }

    int getValue (char entite[]){
        TS p = Recherche(entite);
        return atoi(p->value);
    }
    //* retourner le type de la variable
    int getType(char entite[]){
        TS x= Recherche(entite);
        if( x==NULL) return -1;
        else {
            return x->type;
        }
    }
   
    // la partie instructions ( affectation)

//!---------------- Liste intermediere pour sauvgarder des entité--
    typedef struct params_idf{
        char name[13];
        struct params_idf *suivant;
        }params_idf;
    typedef struct params_idf *TS2;
    TS2 list2=NULL;

    //* Inertion dans la list des params
    void insererparam(char n[]){ 
            TS2 tete, temp;
            tete = (struct params_idf*)malloc(sizeof(struct params_idf));
            if (list2==NULL){
                list2 =tete;
                strcpy(list2->name,n);
                list2->suivant = NULL;
                return;
            }
            temp=list2;
            while(temp->suivant != NULL){
                temp = temp->suivant;
            }
            temp->suivant = tete;
            strcpy(tete->name,n);
            tete->suivant = NULL;

        }



//! --------------- Les Routines -------------------------------------
    //* incompatible type de variables
    int incompatible_type(int type1, int type2){
        if (type1 != type2) { return 0;} // faux : type icompatible
        return 1; // vrai : le mm type
    }
    //partie d'instruction : affectaion 
    //* Variable Non Déclaré     FAIT
    int non_declarer(char name[20]){
        
        TS x= Recherche(name);
        if (x!=NULL){return 1;} //faux : valeur declarer
        else{ return 0;} // vrai : valeur non declarer
    }
    //instructions: affectation
    //partie declaration (on la deja verifier lors de l'insretion)
    //*Modification d'une constant   
    //TODO: le cas ou la cst est declarer vide
    int modification_cst(char name[20]){
        TS x= Recherche(name);
        if (x->nature== 1) { 
             
            return 0;// vrai : on modifie une constante
            }
        return 1 ; // faux: c'est une variable
    }
    //partie instruction : affectation
    //*Division par zero
    int division_par_zero(char entite[] ){
        TS x= Recherche(entite);
        if (x->value==0)  { 
            
            return 0; // valeur null
            }
        return 1; // valeur !=du 0
    }
    //parite instruction: affectation: expression artihemitique


