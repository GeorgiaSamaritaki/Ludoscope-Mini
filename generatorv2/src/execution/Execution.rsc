module execution::Execution

import IO;
import utility::TileMap;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

import execution::Call;

public ExecutionArtifact executeProject(LudoscopeProject project){
	
	println("executeProject");
	ExecutionHistory allHistory = [];
	TileMap currentState = createTileMap(
								project.options.height,
								project.options.width,
								project.options.tiletype);
	ExecutionArtifact artifact = executionArtifact([], currentState, [], []);
	
	for (LudoscopeModule \module <- project.modules){
			artifact = executeModule(artifact, \module);
		    
		    allHistory += artifact.history;
		    artifact.history = [];
	}

	artifact.history = allHistory;
	return artifact;
}
 
public ExecutionArtifact executeModule(
	ExecutionArtifact artifact, 
	LudoscopeModule ldModule
){
	println("execute module");

	RecipeList recipe = ldModule.recipe;
	for (Call call<- recipe){
		artifact = executeCall(artifact, ldModule, call);
		
		artifact.currentState = artifact.output;
	}
	
	return artifact;
}

