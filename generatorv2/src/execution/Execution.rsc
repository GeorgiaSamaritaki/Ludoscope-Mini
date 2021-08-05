module execution::Execution

import IO;
import utility::TileMap;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

import execution::Call;
import execution::Constraints;

public ExecutionArtifact executeProject(LudoscopeProject project){
	
	println("System Message: executeProject");
	ExecutionHistory allHistory = [];
	TileMap currentState = createTileMap(
								project.options.height,
								project.options.width,
								project.options.tiletype);
	ExecutionArtifact artifact = executionArtifact([], currentState, (), [], []);
	
	for (LudoscopeModule \module <- project.modules){
			artifact = executeModule(artifact, \module);
		    if(artifact.errors != []) return artifact;
		    
		    checkExitConstraints(artifact, \module.constraints);
		    
		    allHistory += artifact.history;
		    artifact.history = [];
	}

	artifact.history = allHistory;
	return artifact;
}
 
public ExecutionArtifact executeModule(
	ExecutionArtifact artifact, 
	LudoscopeModule \module 
){
	println("System Message: execute module");

	RecipeList recipe = \module.recipe;
	for (Call call<- recipe){
		artifact = executeCall(artifact, \module , call);
		
		println("checking constraints");
		artifact = checkNonExitConstraints(artifact, \module.constraints);
		if(artifact.errors != []) return artifact;
		
		artifact.currentState = artifact.output;
	}
	
	return artifact;
}










