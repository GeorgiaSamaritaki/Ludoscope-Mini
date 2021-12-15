//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file containts all the functionality of modifiers.
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module execution::Modifiers

import Set;
import List;
import IO;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import execution::DataStructures;

import parsing::DataStructures;
import parsing::AST;

//////////////////////////////////////////////////////////////////////////////////
// Modifier Functions
//////////////////////////////////////////////////////////////////////////////////
private tuple[ExecutionArtifact, TileMap, Coordinates] applyModifiers(
	ExecutionArtifact artifact,
	loc callLoc,
	tuple[int height, int width] ruleSize,
	list[CallModifier] modifiers
){
	Coordinates totalOffset = <0,0>;
	Coordinates tmpOffset = <0,0>;
	
	TileMap modifiedOutput = artifact.currentState;
	
	for(m <- modifiers){
	  <artifact, modifiedOutput, tmpOffset> 
		= applyModifierToMap(artifact, <modifiedOutput, totalOffset>, 
							callLoc, ruleSize, m);
	  
	  totalOffset.x += tmpOffset.x;
	  totalOffset.y += tmpOffset.y;
	  
	}
	return <artifact, modifiedOutput, totalOffset>;
}

private tuple[ExecutionArtifact, TileMap, Coordinates] applyModifierToMap(
	ExecutionArtifact artifact,
	<TileMap \map, Coordinates offset>,
	loc callLoc,
	tuple[int height, int width] ruleSize,
	incl(str varname)
){
	TileMap modifiedArea = [];
	Coordinates locOnMap = <0,0>;
	
	if(varname in artifact.variables){ 
		set[Coordinates] affectedArea = artifact.variables[varname];
		
		// Normalise based on the current offset
		affectedArea = substractOffset(affectedArea, offset);
		
		<locOnMap, modifiedArea> = extractSection(\map, affectedArea);
	
	}else {
		printError("Variable |<varname>| doesnt exist");
		artifact.errors += [variableDoesntExist(varname, callLoc)];
	}  	
	return <artifact, modifiedArea, locOnMap>;
}

private tuple[ExecutionArtifact, TileMap, Coordinates] applyModifierToMap(
	ExecutionArtifact artifact,
	<TileMap \map, Coordinates offset>,
	loc callLoc,
	tuple[int height, int width] ruleSize,
	notIn(str varname)
){
	TileMap modifiedArea = [];
	
	if(varname in artifact.variables){ 
		set[Coordinates] toRemove = {};

		if(varname in artifact.graphs)
			toRemove = toSet(artifact.graphs[varname].path);
		else if(varname in artifact.variables){
			toRemove = artifact.variables[varname];
			toRemove = fillInGaps(toRemove); 
		}else{
			printError("Variable |<varname>| doesnt exist");
			artifact.errors += [variableDoesntExist(varname, callLoc)];
			return <artifact, \map, <0,0>>;
		} 
		
		// Normalise based on the current offset
		toRemove = substractOffset(toRemove, offset);
		//remove them from map
		\map = removeCoordinatesFromTileMap(\map, toRemove);
		
	}else {
		printError("Variable |<varname>| doesnt exist");
		artifact.errors += [variableDoesntExist(varname, callLoc)];
	}  	
	return <artifact, \map, <0,0>>;
}

private tuple[ExecutionArtifact, TileMap, Coordinates] applyModifierToMap(
	ExecutionArtifact artifact,
	<TileMap \map, Coordinates offset>,
	loc callLoc,
	tuple[int height, int width] ruleSize,
	nextTo(str varname)
){
	TileMap modifiedArea = [];
	Coordinates locOnMap = <0,0>;
	if(varname in artifact.variables){ 
		set[Coordinates] affectedArea = artifact.variables[varname];

		// Normalise based on the current offset
		affectedArea = substractOffset(affectedArea, offset);

		<locOnMap, modifiedArea> = 
			getAreaAround(\map, affectedArea, ruleSize);
	}else {
		printError("Variable |<varname>| doesnt exist");
		artifact.errors += [variableDoesntExist(varname, callLoc)];
	}  	
	return <artifact, modifiedArea, locOnMap>;
}

private tuple[ExecutionArtifact, TileMap, Coordinates] applyModifierToMap(
	ExecutionArtifact artifact,
	<TileMap \map, Coordinates offset>,
	loc callLoc,
	tuple[int height, int width] ruleSize,
	notNextTo(str varname)
){
	TileMap modifiedArea = [];

	if(varname in artifact.variables){ 
		set[Coordinates] affectedArea = artifact.variables[varname];
		
		// Normalise based on the current offset
		affectedArea = substractOffset(affectedArea, offset);
		
		modifiedArea = getAllButAreaAround(\map, affectedArea);
	
	}else {
		printError("Variable |<varname>| doesnt exist");
		artifact.errors += [variableDoesntExist(varname, callLoc)];
	}  	
	return <artifact, modifiedArea, <0,0>>;
}


