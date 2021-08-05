module parsing::AST


import parsing::Syntax;
import ParseTree;

////////////////////////////////////////////////
// APIs
////////////////////////////////////////////////

public parsing::AST::Pipeline implodePipeline(Tree tree)
  = implode(#parsing::AST::Pipeline, tree);
  
public parsing::AST::Pipeline parsePipelineToAST(loc location)
  = implodePipeline(LD_parse(location));
  

////////////////////////////////////////////////
// AST
////////////////////////////////////////////////

data Pipeline
 	= pipeline(
 	Alphabet alphabet,
 	Options options,
 	list[Module] modules);
 
data Alphabet
	= alphabet(
	list[SymbolInfo] symbols);
	
data SymbolInfo
	= symbolInfo(
			Name name, 
			str abbreviation,
			str color);
data Options
	= options(
	 	int randomseed, 
		int height,
		int width,
		str tiletype
	);

data Module 
 	= modul(
 		Name name, 
 		Rules rules,
 		Recipe recipe,
 		list[Constraint] constraints
 	);

data Rules 
	= rules(list[Rule] rules);
	
data Rule
	= rule(
		Name name, 
		Pattern leftHand, 
		Pattern rightHand
	);
		
data Pattern
	= pattern(list[str] patterns); 
	
data Recipe
 	= recipe(list[Call] calls);
 
data Call
	= rulename(str name)
	| createGraph(str graphname, CreateGraph graph) 
	;

data CreateGraph
	= createPath(str a, str b)
	;
	
data Constraint 
 	= constraint(ConstraintType typ,
 	Name name, 
 	Expression exp); //maybe make it boolean?

data Expression
	= e_val(Value val)
	| o_par(Expression exp)
	| e_not(Expression exp)
	| e_lt(Expression lhs, Expression rhs)
	| e_gt(Expression lhs, Expression rhs)
	| e_le(Expression lhs, Expression rhs)
	| e_ge(Expression lhs, Expression rhs)
	| e_neq(Expression lhs, Expression rhs)
	| e_eq(Expression lhs, Expression rhs);

data ConstraintType
	= onexit() 
	| resolvable()
	| nonresolvable()
	;
	
data Value
 	= integer(int integer)
 	| boolean(bool boolean)
 	| char(str char)
 	| path() ;
	
data Name 
 	= name(str val);
 