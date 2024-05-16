//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   Syntax for .lm files.
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module parsing::Syntax

import ParseTree;

layout Whitespace = [\t-\r\ ]*;

lexical BOOLEAN
	= @category="Boolean" "true" | "false";

lexical NAME
  = @category="Name" name: 
  ([a-zA-Z_$] [a-zA-Z0-9_$]* !>> [a-zA-Z0-9_$]) \ Keywords ;

lexical STRING
  = @category="Name" ![\n]+ >> [\n];

lexical CHAR
  = @category="Character" [a-zA-Z_$.*~|];
 
lexical PATTERNCHAR
	= CHAR | ",";
	
lexical COLORCODE
	= @category="ColorCode" "#" [0-9A-Z]*;
 
lexical INTEGER
  = @category="Integer" "-"?[0-9]+;
  
lexical FLOAT
  = INTEGER ([.][0-9]+?)? "f";
    

lexical ConstraintKeywords 
	= @categoty = "ConstraintKeywords"	"on exit" | "resolvable" | "Exists" | "Count" | "Intact" ;
	
keyword Keywords = 'module' | 'recipe' | 'alphabet' | 'constraint' | 'options' | 'pipeline' | 'seed';

start syntax Pipeline 
	= pipeline: "pipeline" "{" 
		Alphabet alphabet
	 	Options options 
	 	Module+ modules
	 	Constraint* constraints
	 	Handlers? handlers
	 "}";

syntax Alphabet
	= alphabet: 
	"alphabet" "{" 
		SymbolInfo+ symbols 
	"}"
	;

syntax SymbolInfo
 	= symbolInfo: NAME name CHAR abbreviation COLORCODE color ";"
 	;
 
syntax Options
	= options: "options" "{"
	"seed:" INTEGER randomseed ";"
	"size:" INTEGER height "x" INTEGER width ";"
	"tiletype:" CHAR tiletype ";"
	"}"
	;
	//("crossableTiles:" {CHAR t ","}+ )?

syntax Module
    = modul: "module"  NAME name "{"
		Rules rules
	 	Recipe recipe
	 	Constraint* constraints
	"}"
	;

syntax Rules
	= rules: "rules" "{" 
	Rule* rules
	"}"
	;

syntax Rule
	= rule: NAME name ":" 
		Pattern leftHand "-\>" Pattern rightHand ";"
	;

syntax Pattern 
	= pattern: PATTERNCHAR+ patterns
	;
	
syntax Recipe
    = recipe: "recipe" "{" 
    Call* calls 
    "}"
	;

//This can be greatly simplified however everything i tried is failing	
syntax Call
   	= call: NAME ruleName ";" 
   	| assignCall: NAME varname "=" NAME ruleName ";"
   	| appendCall: NAME varname "+="  NAME ruleName  ";" 
   	
   	| callM: NAME ruleName "[" CallModifier modifier ("\>" CallModifier modifier)* "]" ";" 
   	| assignCallM: NAME varname "=" NAME ruleName "[" CallModifier modifier ("\>" CallModifier modifier)* "]" ";"
   	| appendCallM: NAME varname "+="  NAME ruleName "[" CallModifier modifier ("\>" CallModifier modifier)* "]" ";" 
   	
   	| createPath: NAME varname "=" "CreatePath" "("  NAME a "," NAME b ")" ";" 
   	| activateConstraint: "activate" "(" NAME constraintName ")" ";"
	;
   	  
syntax CallModifier
	= incl: "in" NAME varname 
	| notIn: "notIn" NAME varname 
	| nextTo: "nextTo" NAME varname 
	| notNextTo: "notNextTo" NAME varname 
	;
	
syntax Constraint
    = constraint: 
    ConstraintType typ "constraint" 
    NAME constraint_name ":"  
    Expression exp ";"
    | empty: ";";
    
syntax ConstraintType
	= onexit: "on exit"
	| resolvable: "resolvable"
	| nonresolvable: "non resolvable" 
	;

syntax Expression
	= e_val: Value val
	| func: FunctionType ft "(" NAME varName  ")"
	| incl: NAME var1 "in" NAME var2
	| o_par: "(" Expression exp ")"
	| e_not: "!" Expression exp
	> left
	  ( e_lt: Expression lhs "\<" Expression rhs
	  | e_gt: Expression lhs "\>" Expression rhs
	  | e_le: Expression lhs "\<=" Expression rhs
	  | e_ge: Expression lhs "\>=" Expression rhs
	  | e_neq: Expression lhs "!=" Expression rhs
	  | e_eq: Expression lhs "==" Expression rhs
	  )
	;

syntax FunctionType
	= count: "Count"
	| exists: "Exists"
	| intact: "Intact"
	;

syntax Value
	= integer: INTEGER integer
	| boolean: BOOLEAN boolean
	| varName: NAME name 
	;

syntax Handlers
	= "handlers" "{" 
		Handler* handlers 
	"}";

syntax Handler 
	= handler: NAME name "{" 
		HandlerCall* hcalls
	"}";

syntax HandlerCall
	= clearPath: "ClearPath" "(" CHAR tileType "," NAME constraintName ")" ";"
	| reverseM: "ReverseChangesByLastModule" "(" ")" ";"
	| executeM: "ExecuteModule" "("NAME moduleName")" ";"
	| ";";

//////////////////////////////////////////////////	
//LD parsers
//////////////////////////////////////////////////

public start[Pipeline] LD_parse(str src) = 
  parse(#start[Pipeline], src);

public start[Pipeline] LD_parse(str src, loc file) = 
  parse(#start[Pipeline], src, file);
  
public start[Pipeline] LD_parse(loc file) =
 parse(#start[Pipeline], file);
