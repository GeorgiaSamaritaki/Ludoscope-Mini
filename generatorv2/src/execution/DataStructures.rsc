module execution::DataStructures

import parsing::DataStructures;
import errors::Execution;

alias ModuleHierarchy = list[set[LudoscopeModule]];
alias Location =  tuple[int x, int y];
alias PathMap = map[str, Path];

data ExecutionArtifact =
	executionArtifact(
		TileMap output,
		TileMap currentState,
		PathMap graphs,
		ExecutionHistory history,
		list[str] errors)
	| emptyExecutionArtifact();

data Path =
	path(
		str from,
		str to,
		list[Coordinates] path
	);
	
alias ExecutionHistory = list[HistoryEntry];

data HistoryEntry = 
	entry(
		TileMap before,
		TileMap after,
		list[Coordinates] coordinates,
		str moduleName, 
		str ruleName);
		