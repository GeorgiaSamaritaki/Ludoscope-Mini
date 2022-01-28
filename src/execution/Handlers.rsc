//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file containts the very primitive implementation of  
//		    constraints
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module execution::Handlers

import IO;
import List;
import Set;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import parsing::DataStructures;
import execution::DataStructures;
import execution::Execution;
import parsing::AST;

import List;

int maxHandlerCalls = 10;

public ExecutionArtifact callHandler(str constraintName, ExecutionArtifact artifact){
	if(constraintName notin artifact.handlers){
		printError("No handler with name <constraintName>");
	 	artifact.errors += [undefinedHandler(constraintName)];
	 	return artifact;
	}
	list[HandlerCall] calls = artifact.handlers[constraintName];
	
	for(c <- calls) artifact = handlerCall(artifact, constraintName, c);
	
	
	return artifact;
}

private ExecutionArtifact handlerCall(
	ExecutionArtifact artifact,
	str constraintName,
	clearPath(str tileType, str varName)
){
	return clearPath(tileType, varName, artifact);
}

private ExecutionArtifact handlerCall(
	ExecutionArtifact artifact,
	str constraintName,
	reverseM()
){
	return reverseChangesByLastModule(constraintName, artifact);
}

private ExecutionArtifact handlerCall(
	ExecutionArtifact artifact,
	str constraintName,
	executeM(str moduleName)
){
	
	return executeModule(constraintName, moduleName, artifact);
}



//////////////////////////////////////////////////////////////////////////////////////////////
//Helper
//////////////////////////////////////////////////////////////////////////////////////////////
private ExecutionArtifact executeModule(
	str cname, 
	str moduleName,
	ExecutionArtifact artifact
){
	LudoscopeModule m = getModule(moduleName);
	return executeModuleNoConstraints(artifact,m);
}

private ExecutionArtifact reverseChangesByLastModule(
	str cname, 
	ExecutionArtifact artifact
){
	if(isEmpty(artifact.history)) return artifact;
	
	str moduleName = last(artifact.history).moduleName;
	TileMap before = artifact.currentState;
	
	for(e <- artifact.history, e.moduleName == moduleName){ 
		artifact.currentState = e.before;
		break;
	}
	
	artifact.history += [ entry(
		before,
		artifact.currentState,
		 tilemapDifference(before, artifact.currentState), //every tile affected
		"System", 
		"Handler for <cname>")];
	return artifact;
}

private ExecutionArtifact clearPath(str convertTile, str varName, ExecutionArtifact artifact){
	HistoryEntry lastEntry = last(artifact.history);
	
	if(varName notin artifact.graphs){
	 	artifact += [undefinedVariable(varName)];
	 	return artifact;
	}
	Path p = artifact.graphs[varName];
	list[Coordinates] intersection = toList(lastEntry.coordinates) & p.path;
	
	HistoryEntry newEntry = entry(
								artifact.output,
								[],
								toSet(intersection),
								"System",
								"Handler for ClearPath");
	for(c <- intersection){
		artifact.output = changeTile(convertTile, c, artifact.output);
	}
	newEntry.after = artifact.output;
	artifact.history += [newEntry];
	
	return artifact;
}