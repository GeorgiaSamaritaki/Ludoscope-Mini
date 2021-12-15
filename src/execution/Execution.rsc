//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file containts the main execution functions
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module execution::Execution

import IO;
import utility::TileMap;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

import execution::Call;
import execution::Constraints;

import errors::Execution;

LudoscopeProject ldproject;

public ExecutionArtifact executeProject(LudoscopeProject project){
	
	printSM("Execute Project");
	ldproject = project;
	ExecutionHistory allHistory = [];
	TileMap currentState = createTileMap(
								project.options.height,
								project.options.width,
								project.options.tiletype);
	ExecutionArtifact artifact = getEmptyExecutionArtifact();
	artifact.currentState = currentState;
	artifact.handlers = project.handlers;
	
	for (LudoscopeModule \module <- project.modules){
	    printError("Executing module <\module.name>");
	    
		//Saving current state to make the variable with the module's name
		TileMap input = artifact.currentState;
		
		artifact = executeModule(artifact, \module);
	    println("returned module");
	    //Create the variable for module
	    TileMap output = artifact.currentState;

		//Add changes to history	    
	    allHistory += artifact.history;
	    artifact.history = [];
	    
	    if(artifact.errors != []) break;

	    artifact.variables[\module.name] = tilemapDifference(input, output);	    
	}
	
	if(artifact.errors == [])
		artifact = checkExitConstraints(artifact, project.constraints);
	
	artifact.history = allHistory;
	return artifact;
}
 
public ExecutionArtifact executeModule(
	ExecutionArtifact artifact, 
	LudoscopeModule \module 
){

	RecipeList recipe = \module.recipe;
	for (Call call<- recipe){
		artifact = executeCall(artifact, \module , call);
		artifact = checkNonExitConstraints(artifact, \module.constraints);
		
		artifact.currentState = artifact.output;
		if(artifact.errors != []) return artifact;
	}
	if(artifact.errors == [])
		artifact = checkExitConstraints(artifact, \module.constraints);
	
	return artifact;
}

public ExecutionArtifact executeModuleNoConstraints(
	ExecutionArtifact artifact, 
	LudoscopeModule \module 
){

	RecipeList recipe = \module.recipe;
	for (Call call<- recipe){
		artifact = executeCall(artifact, \module , call);
		
		
		artifact.currentState = artifact.output;
		if(artifact.errors != []) return artifact;
	}
	
	artifact = checkNonExitConstraints(artifact, \module.constraints);
	if(artifact.errors == []) 
		artifact = checkExitConstraints(artifact, \module.constraints);
	
	return artifact;
}

public LudoscopeModule getModule(str \moduleName){
	return [m | m <- ldproject.modules, m.name == \moduleName][0];
}






