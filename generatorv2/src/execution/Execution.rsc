module execution::Execution

import IO;
import utility::TileMap;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

import execution::Call;
import execution::Constraints;

import errors::Execution;

public ExecutionArtifact executeProject(LudoscopeProject project){
	
	printSM("executeProject");
	ExecutionHistory allHistory = [];
	TileMap currentState = createTileMap(
								project.options.height,
								project.options.width,
								project.options.tiletype);
	ExecutionArtifact artifact = getEmptyExecutionArtifact();
	artifact.currentState = currentState;
	
	for (LudoscopeModule \module <- project.modules){
		TileMap input = artifact.currentState;
	
		artifact = executeModule(artifact, \module);
	    
	    checkExitConstraints(artifact, \module.constraints);
	    
	    //Create the variable for module
	    TileMap output = artifact.currentState;
	    
	    artifact.variables[\module.name] = tilemapDifference(input,output);
	    
	    allHistory += artifact.history;
	    artifact.history = [];
	    if(artifact.errors != []) break;
	}

	artifact.history = allHistory;
	return artifact;
}
 
public ExecutionArtifact executeModule(
	ExecutionArtifact artifact, 
	LudoscopeModule \module 
){
	printSM("execute module");

	RecipeList recipe = \module.recipe;
	for (Call call<- recipe){
		artifact = executeCall(artifact, \module , call);
		
		printError("checking constraints");
		artifact = checkNonExitConstraints(artifact, \module.constraints);
		
		artifact.currentState = artifact.output;
		if(artifact.errors != []) return artifact;
	}
	
	return artifact;
}










