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
 
anno loc Pipeline@location;
anno loc Alphabet@location;
anno loc SymbolInfo@location;
anno loc Options@location;
anno loc Module@location;
anno loc Rules@location;
anno loc Rule@location;
anno loc Pattern@location;
anno loc Recipe@location;
anno loc Call@location;
anno loc Expression@location;
anno loc ConstraintType@location;



////////////////////////////////////////////////
// AST
////////////////////////////////////////////////

data Pipeline
 	= pipeline(
 	Alphabet alphabet,
 	Options options,
 	list[Module] modules,
 	list[Constraint] constraints
 	);
 
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
	)
	| undefined();

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
	= call(str ruleName)
	| assignCall(str varname, str ruleName)
	| appendCall(str varname, str ruleName)
	| callM(str ruleName, CallModifier m, list[CallModifier] modifiers)
	| assignCallM(str varname, str ruleName, CallModifier modifier)
	| appendCallM(str varname, str ruleName, CallModifier modifier)
   	| createPath(str varname, str a, str b)
   	| activateConstraint(str constraintName)
	;

data CallModifier
	= incl(str varname)
	| nextTo(str varname)
	| notNextTo(str varname)
	;
	
data Constraint 
 	= constraint(ConstraintType typ,
 	str name, 
 	Expression exp)
 	| empty(); 

data Expression
	= e_val(Value val)
	| func(FunctionType ft, Name varName)
	| incl(str var1, str var2) 
	| o_par(Expression exp)
	| e_not(Expression exp)
	| e_lt(Expression lhs, Expression rhs)
	| e_gt(Expression lhs, Expression rhs)
	| e_le(Expression lhs, Expression rhs)
	| e_ge(Expression lhs, Expression rhs)
	| e_neq(Expression lhs, Expression rhs)
	| e_eq(Expression lhs, Expression rhs);

data FunctionType
	= count()
	| exists()
	| intact()
	;

data ConstraintType
	= onexit() 
	| resolvable()
	| nonresolvable()
	;
	
data Value
 	= integer(int integer)
 	| boolean(bool boolean)
	| varName(Name name)
	;
	
data Name 
 	= name(str val);
 