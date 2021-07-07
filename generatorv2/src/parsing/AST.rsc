module parsing::AST


import parsing::Syntax;
import ParseTree;

data Program
 = program(int randomseed, list[Module] modules);
 
data Module 
 = modul(
 		str name, 
 		list[Contraint] constraints, 
 		list[Rule] rules, 
 		Recipe recipe
 	);
 	
data Rule
	= rule(
		str name, 
		Pattern leftHand, 
		Pattern rightHands
	);
		
data Pattern
	= pattern(list[list [char]] pattern); // can have multiple lines
	
data Contraint 
 = constraint(Expression exp); //maybe make it boolean?

data Line
 = line(str l);
 
data Recipe
 = recipe(list[str] rule_names);
 
data Name 
 = name(ID id);
 
data ID
 = id(str val);