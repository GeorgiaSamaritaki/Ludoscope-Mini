module parsing::DataStructures

import errors::Parsing;
import parsing::AST;

alias AbstractPipeline = parsing::AST::Pipeline;
alias AbstractModuleList = list[parsing::AST::Module];

alias TileMap = list[list[Tile]];
alias Tile = str;

alias RuleMap	= map[str, Rule];
alias RuleName = str;
alias Model = list[ModelType];

alias History = list[Transformation];
alias Transformation = str;

data SyntaxTree
	= syntaxTree(
	list[parsing::AST::Pipeline] pipeline,
	list[ParsingError] errors); 
	 
data TransformationArtifact
	= transformationArtifact(
		LudoscopeProject project, 
		list[ParsingError] errors)
	| emptyArtifact();

data LudoscopeProject
	= ludoscopeProject(
		list[LudoscopeModule] modules, 
		Alphabet alphabet,
		History history
		)
	| undefinedProject();
	
data LudoscopeModule
	= ludoscopeModule(str name,
		TileMap startingState, 
		RuleMap rules, 
		Recipe recipe,
		Model model)
	| undefinedModule();
	
data Rule
	= rule(Name name, 
		TileMap lhs, 
		TileMap rhs);
	
data Coordinates
	= coordinates(int x, int y);
	
data ModelType
	= makePath(str pointA, str pointB)
	| destroyPath(str pointA, str pointB);
