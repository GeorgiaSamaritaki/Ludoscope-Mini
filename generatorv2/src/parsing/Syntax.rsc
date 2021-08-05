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
	= @categoty = "ConstraintKeywords"	"on exit" | "resolvable";
	
keyword Keywords = 'module' | 'recipe' | 'alphabet' | 'constraint' | 'options' | 'pipeline' | 'seed';

start syntax Pipeline 
	= pipeline: "pipeline" "{" 
		Alphabet alphabet
	 	Options options 
	 	Module+ modules
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

syntax Module
    = modul: "module"  NAME name "{"
	Rules rules
 	Recipe recipe
 	Constraint+ constraints
	"}"
	;

syntax Rules
	= rules: "rules" "{" 
	Rule+ rules
	"}"
	;

syntax Rule
	= rule: 
		NAME name ":" 
		Pattern leftHand "-\>" Pattern rightHand ";"
	;

syntax Pattern 
	= pattern: PATTERNCHAR+ patterns
	;
	
syntax Recipe
    = recipe: "recipe" "{" 
    Call+ calls 
    "}"
	;
	
syntax Call
   	= rulename: NAME ruleName ";"
   	| createGraph: NAME graphname "=" CreateGraph graph ";"
	;
   	  
syntax CreateGraph
    = createPath: "CreatePath" "(" CHAR "," CHAR ")";

syntax Constraint
    = constraint: 
    ConstraintType typ "constraint" 
    NAME constraint_name ":"  
    Expression ";";
    
syntax ConstraintType
	= onexit: "on exit"
	| resolable: "resolvable"
	| nonresolvable: "non resolvable" 
	;

syntax Expression
	= e_val: Value val
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
syntax Value
	= integer: INTEGER integer
	| boolean: BOOLEAN boolean
	| char: CHAR char
	| path: "path"
	;
	
//////////////////////////////////////////////////	
//LD parsers
//////////////////////////////////////////////////

public start[Pipeline] LD_parse(str src) = 
  parse(#start[Pipeline], src);

public start[Pipeline] LD_parse(str src, loc file) = 
  parse(#start[Pipeline], src, file);
  
public start[Pipeline] LD_parse(loc file) =
 parse(#start[Pipeline], file);
