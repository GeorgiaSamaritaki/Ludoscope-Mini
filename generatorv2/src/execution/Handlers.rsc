module execution::Handlers

import IO;
import List;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

public ExecutionArtifact callHandler(str constraintName, ExecutionArtifact artifact){
	switch(constraintName){
		case /inner_path/: 
				return pathCheck(constraintName, artifact);
		default: 
			artifact += [undefinedHandler(constraintName)];
	}
	return artifact;
}

//
//This is called when the path is broken
//
private ExecutionArtifact pathCheck(str constraintName, ExecutionArtifact artifact){
	artifact = clearPath("f", constraintName, artifact);
	return artifact;
}

//////////////////////////////////////////////////////////////////////////////////////////////
//Helper
//////////////////////////////////////////////////////////////////////////////////////////////

private ExecutionArtifact clearPath(str convertTile, str constraintName, ExecutionArtifact artifact){
	HistoryEntry lastEntry = last(artifact.history);
	Path p = artifact.graphs[constraintName];
	list[Coordinates] intersection = lastEntry.coordinates & p.path;
	
	HistoryEntry newEntry = entry(
								artifact.output,
								[],
								intersection,
								"Repair",
								"Path");
	for(c <- intersection){
		artifact.output = changeTile(convertTile, c, artifact.output);
	}
	newEntry.after = artifact.output;
	artifact.history += [newEntry];
	
	return artifact;
}