module parsing::Syntax

import ParseTree;

layout Whitespace = [\t-\n\r\ ]*;

lexical BOOLEAN
	= @category="Boolean" "true" | "false";

lexical NAME
  = @category="Name" ([a-zA-Z_$.] [a-zA-Z0-9_$.]* !>> [a-zA-Z0-9_$.]) \ Keywords;

lexical CHAR
  = @category="Character" [a-zA-Z0-9_$|~!@#$%^&*+-.];


lexical COLORCODE
	= @category="ColorCode" "#" [0-9A-Z]*;
 
lexical INTEGER
  = ("-"?[0-9]+);
  
lexical FLOAT
  = INTEGER ([.][0-9]+?)? "f";
    
lexical STRING
  = ![\"]*;

lexical EMPTY = [\n] | " " | "" | "\t"; //whitespace

lexical ConstraintKeywords = "on exit" | "resolvable";
keyword Keywords = 'seed' | 'module' | 'recipe' | 'alphabet' | 'contraint' | 'options' | 'pipeline';

start syntax Pipeline 
	= pipeline: "pipeline" NAME pipeline_name "{" 
		("seed:" INTEGER randomseed ";")?
		Alphabet? 
	 	Options? 
	 	Module+ 
	 "}";

syntax Alphabet
	= alphabet: 
	"alphabet" "{" 
		SymbolInfo+  symbols 
	"}"
	;
	
syntax SymbolInfo
 	= symbolInfo: NAME name CHAR abbreviation COLORCODE color ";"
 	| empty: 
 	;
 
syntax Options
	= options: "options" "{"
	"size:" INTEGER height "x" INTEGER width ";"
	("tiletype:" CHAR tiletype ";")?
	"}"
	;

syntax Module
    = modul: "module" NAME name "{" 
	Rules? 
 	Recipe? 
 	Constraint+? 
	"}"
	| empty: ;

syntax Rules
	= rules: 'rules' "{" Rule+ rules"}"
	;
	
syntax Rule
	= rule: 
		NAME name ":" 
		Pattern leftHand "-\>" 
		Pattern rightHand ";"
	| empty: 
	;

lexical Pattern 
	= content: STRING s
	;
	
syntax Recipe
    = recipe: 'recipe' "{" Call+ calls "}"
	;
	
syntax Call
   	= rulename: NAME ruleName ";"
   	| createGraph: CreateGraph graph ";"
	| empty: ";"   
	| empty:   
	;
   	  
syntax CreateGraph
    = createPath: "CreatePath" "(" CHAR CHAR ")";

syntax Constraint
    = constraint: 
    ConstraintType type "constraint" 
    NAME constraint_name ":"  
    Expression ";";
    
syntax ConstraintType
	= onexit: "on exit"
	| resolable: "resolvable"
	| none: "";

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
	= name: NAME name
	| boolean: BOOLEAN bool
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
