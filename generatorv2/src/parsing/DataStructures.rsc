module parsing::DataStructures

import errors::Parsing;
import parsing::AST;

alias AbstractPipeline = parsing::AST::Pipeline;
alias AbstractModuleList = list[parsing::AST::Module];

alias TileMap = list[list[Tile]];
alias Tile = str;

alias RuleMap	= map[str, LudoscopeRule];
alias RecipeList = list[Call];

alias History = list[Transformation];
alias Transformation = str;
alias Coordinates = tuple[int x, int y];

data TransformationArtifact
	= transformationArtifact(
		LudoscopeProject project, 
		list[ParsingError] errors)
	| emptyArtifact();

data LudoscopeProject
	= ludoscopeProject(
		Alphabet alphabet,
		Options options,
		list[LudoscopeModule] modules, 
		History history
		)
	| undefinedProject();
	
data LudoscopeModule
	= ludoscopeModule(str name,
		RuleMap rules, 
		RecipeList recipe,
		list[Constraint] constraints)
	| undefinedModule();

data LudoscopeRule
	= ludoscopeRule(
		TileMap lhs,
		TileMap rhs
	);

	
