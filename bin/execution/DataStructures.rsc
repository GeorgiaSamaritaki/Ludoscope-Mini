//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file containts the data structures utilised  
//		    during execution
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// 			(inspired by Ludoscope Lite from Quinten Heijn)
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module execution::DataStructures

import parsing::DataStructures;
import errors::Execution;
import utility::TileMap;

alias ModuleHierarchy = list[set[LudoscopeModule]];
alias Location =  tuple[int x, int y];
alias PathMap = map[str, Path];
alias VariableMap = map[str, set[Coordinates]];

data ExecutionArtifact =
	executionArtifact(
		TileMap output,
		TileMap currentState,
		PathMap graphs,
		VariableMap variables,
		HandlerMap handlers,
		ExecutionHistory history,
		list[ExecutionError] errors)
	| emptyExecutionArtifact();

data Path =
	path(
		Coordinates from,
		Coordinates to,
		list[Coordinates] path
	);
	
alias ExecutionHistory = list[HistoryEntry];

data HistoryEntry = 
	entry(
		TileMap before,
		TileMap after,
		set[Coordinates] coordinates,
		str moduleName, 
		str ruleName);

public ExecutionArtifact getEmptyExecutionArtifact() =
	executionArtifact([], [], (), (), (), [], []);

public str printHistrory(ExecutionArtifact artifact){
	str s= "";
	for(entry <- artifact.history)
		s += "<entry.moduleName>:<entry.ruleName>\n";
	return s;
}