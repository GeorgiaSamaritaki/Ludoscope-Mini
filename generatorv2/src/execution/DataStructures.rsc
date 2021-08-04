//////////////////////////////////////////////////////////////////////////////
//
// Execution Data Structures
// @brief        This file contains datastructures needed for execution an LL
//							 project.
// @contributor  Quinten Heijn - samuel.heijn@gmail.com - UvA
// @date         01-05-2018
//
//////////////////////////////////////////////////////////////////////////////

module execution::DataStructures

//import analysis::sanrWrapper::PropertyHistory;
//import sanr::PropertyValidation;
//import execution::history::DataStructures;
import parsing::DataStructures;
import errors::Execution;

//import sanr::DataStructures;

alias ModuleHierarchy = list[set[LudoscopeModule]];
alias Location =  tuple[int x, int y];

data ExecutionArtifact =
	executionArtifact(
		TileMap output,
		TileMap currentState,
		list[Graph] graphs,
		ExecutionHistory history,
		list[str] errors)
	| emptyExecutionArtifact();

data Graph =
	graph(
		str from,
		str To,
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
		