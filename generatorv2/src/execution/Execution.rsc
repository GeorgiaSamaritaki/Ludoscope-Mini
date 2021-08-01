module execution::Execution

import IO;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

import execution::Call;

public ExecutionArtifact executeProject(LudoscopeProject project){
	
	/* Initiliaze Property Report */
	//LudoscopeModule ludoscopeModule = getOneFrom(preparationArtifact.hierarchy[0]);
	//int width = size(ludoscopeModule.startingState[0]);
	//int height = size(ludoscopeModule.startingState);
	//PropertyReport propertyReport = 
	//	initializeReport(width, height, project.specification);
	//	
	println("executeProject");
	ExecutionHistory allHistory = [];
	TileMap currentState = createTileMap(
								project.options.height,
								project.options.width,
								project.options.tiletype);
	ExecutionArtifact artifact = executionArtifact([], currentState, [], []);
	
	for (LudoscopeModule \module <- project.modules){
			artifact = executeModule(artifact, \module);
		    println("new artifact: \n <artifact>");
		    
		    allHistory += artifact.history;
		    artifact.history = [];
			artifact.currentState = artifact.output;
	}
	//artifact.history = reverse(artifact.history);
	artifact.history = allHistory;
	return artifact;
}
 
public ExecutionArtifact executeModule(
	ExecutionArtifact artifact, 
	LudoscopeModule ldModule
){
	println("execute module");

	RecipeList recipe = ldModule.recipe;
	for (Call call<- recipe)
		artifact = executeCall(artifact, ldModule, call);

	return artifact;
}

////////////////////////////////////////////////////////////////////////////////
//// Utility functions.
//////////////////////////////////////////////////////////////////////////////// 

private TileMap createTileMap(int height, int width, Tile tiletype){
	list[list[str]] tilemap = [];
	for(int i <- [0..height]){
		list[str] row = [];
		for(int i <- [0..width])
			row += tiletype;
		tilemap += [row];
	}
	return tilemap;
}

private ExecutionArtifact registerOutputToHistory(ExecutionArtifact artifact){

	return artifact;
}
////private ExecutionHistory reverseHistory(ExecutionHistory history)
////{
////	history = visit (history)
////	{
////		case list[ModuleExecution] timeline => reverse(timeline)
////		case list[InstructionExecution] timeline => reverse(timeline)
////		case list[RuleExecution] timeline => reverse(timeline)
////	};
////	return history;
