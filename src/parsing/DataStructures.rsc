//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   The data structures used for parsing. 
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module parsing::DataStructures

import parsing::AST;
import errors::Parsing;

import utility::TileMap;

alias AbstractPipeline = parsing::AST::Pipeline;
alias AbstractModuleList = list[parsing::AST::Module];

alias RuleMap	= map[str, LudoscopeRule];
alias RecipeList = list[Call];
alias AlphabetMap = map [str, AlphabetEntry];
alias HandlerMap = map [str, list[HandlerCall]];


alias History = list[Transformation];
alias Transformation = str;

data TransformationArtifact
	= transformationArtifact(
		LudoscopeProject project, 
		list[ParsingError] errors)
	| emptyArtifact();

data LudoscopeProject
	= ludoscopeProject(
		AlphabetMap alphabet,
		Options options,
		list[LudoscopeModule] modules, 
		list[Constraint] constraints,
		HandlerMap handlers,
		History history
		)
	| undefinedProject();
	
data LudoscopeModule
	= ludoscopeModule(str name,
		RuleMap rules, 
		RecipeList recipe,
		list[Constraint] constraints)
	| undefinedModule();

data AlphabetEntry
	= alphabetEntry(
		str name,
		str color
	);
	
data LudoscopeRule
	= ludoscopeRule(
		TileMap lhs,
		TileMap rhs
	);

public TransformationArtifact getEmptyTransformationArtifact() =
	transformationArtifact(ludoscopeProject(
			(), //AlphabetMap
			undefined(), // Options
			[], //modules
			[],
			(),
			[] //History
		), []);
	
