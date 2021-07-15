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
 	int randomseed, 
 	Alphabet alphabet);
 	//Options options,
 	//list[Module] modules);
 
data Alphabet
	= alphabet();
	//list[SymbolInfo] symbols);
	
data SymbolInfo
	= symbolInfo(
			str name, 
			str abbreviation,
			str color);
data Options
	= options(
		int height,
		int width,
		str tiletype
	);

data Module 
 	= modul(
 		str name, 
 		Rules rules, 
 		Recipe recipe,
 		list[Contraint] constraints
 	);

data Rules 
	= rules(list[Rule] rules);
	
data Rule
	= rule(
		str name, 
		Pattern leftHand, 
		Pattern rightHand
	);
		
data Pattern
	= pattern(str pattern); //will initially be a strin
	
data Recipe
 	= recipe(list[Call] calls);
 
data Call
	= rulename(str name)
	| createGraph(CreateGraph graph) 
	;

data CreateGraph
	= createPath(str a, str b)
	;
	
data Contraint 
 	= constraint(Expression exp); //maybe make it boolean?

data Expression
	= expression();
	
data Name 
 	= name(str val);
 