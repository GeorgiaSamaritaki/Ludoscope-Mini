module execution::Call

import Set;
import List;
import IO;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import execution::DataStructures;

import parsing::DataStructures;
import parsing::AST;


public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	c:call(str ruleName)
){
	return call(artifact, \module, ruleName, c@location, artifact.currentState,
			<0,0>, "", false);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	a:assignCall(str varname, str ruleName)
){
	return call(artifact, \module, ruleName, a@location, artifact.currentState,
			<0,0>, varname, true);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	a:appendCall(str varname, str ruleName)
){
	return call(artifact, \module, ruleName, a@location, artifact.currentState,
			<0,0>, varname, false);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	c:callM(str ruleName, CallModifier m, list[CallModifier] modifiers)
){
	TileMap modifiedArea = [];
	Coordinates offset = <0,0>;
	
	<artifact, modifiedArea, offset> = 
		applyModifiers(artifact, c@location, 
						patternSize(\module.rules[ruleName].lhs),
						m + modifiers);
	
	if(modifiedArea == []){
		printError("Not applicable modifier");
		artifact.errors += [notAppliableModifier(c@location)];
		return artifact;
	}

	return call(artifact, \module, ruleName, c@location, 
			modifiedArea,
			offset, "", false);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	a:assignCallM(str varname, str ruleName, CallModifier m, list[CallModifier] modifiers)
){
	TileMap modifiedArea = [];
	Coordinates offset = <0,0>;
	
	<artifact, modifiedArea, offset> = 
		applyModifiers(artifact, a@location, 
						patternSize(\module.rules[ruleName].lhs),
						m + modifiers);
						
	if(modifiedArea == []){
		printError("Not applicable modifier");
		artifact.errors += [notAppliableModifier(a@location)];
		return artifact;
	}
	
	return call(artifact, \module, ruleName, a@location, modifiedArea,
			offset, varname, true);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	a:appendCallM(str varname, str ruleName, CallModifier m, list[CallModifier] modifiers)
){
	TileMap modifiedArea = [];
	Coordinates offset = <0,0>;
	
	<artifact, modifiedArea, offset> = 
		applyModifiers(artifact, a@location, 
						patternSize(\module.rules[ruleName].lhs),
						m + modifiers);
						
	if(modifiedArea == []){
		printError("Not applicable modifier");
		artifact.errors += [notAppliableModifier(a@location)];
		return artifact;
	}
	
	return call(artifact, \module, ruleName, a@location, modifiedArea,
			offset, varname, false);

}

//////////////////////////////////////////////////////////////////////////////////
// Universal Call function
//////////////////////////////////////////////////////////////////////////////////

private ExecutionArtifact call(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	str rulename,
	loc ruleLocation,
	TileMap \map,
	Coordinates offset, //If the map is a submap, then we need its location to replace it in the current map
	str varname,
	bool toAssign
){
	LudoscopeRule rule = \module.rules[rulename];
	
	//Find if the pattern matches
	set[Coordinates] matches = 
		findPatternInGrid(\map, rule.lhs);
	
	if(isEmpty(matches)) {
		printError("No matches found for rule <rulename> in tilemap");
		artifact.errors += [couldNotApplyRule(rulename, ruleLocation)];
		return artifact;
	}
	
	//Transform the tilemap
	Coordinates match = getOneFrom(matches); //defined by the arbSeed function
	match.x += offset.x; 
	match.y += offset.y;
	
	//printError("Match <match>: with offset <match.x + offset.x>, <match.y + offset.y>");
	artifact.output = replacePattern(artifact.currentState, rule.rhs, match);
	
	//If it was added to a variable
	if(varname != ""){
		set[Coordinates] changes = tilemapDifference(artifact.currentState, artifact.output);
		//Simple assignment 
		if(toAssign){
			artifact.variables[varname] = changes;
		}else{ //appendCall
			if(varname in artifact.variables) //if it exists expand the var
				artifact.variables[varname] += changes;
			else {
				printError("Variable <varname> that you are trying to append to
						doesnt exist");
				artifact.errors += [variableDoesntExist(varname, ruleLocation)];
				return artifact;
			}  	
		}
	}
	
	artifact.history += [ entry(
		artifact.currentState,
		artifact.output,
		getAllCoordinates(match, patternSize(rule.lhs)), //every tile affected
		\module.name, 
		rulename)];
	
	return artifact;
}

//////////////////////////////////////////////////////////////////////////////////
// Path calls
//////////////////////////////////////////////////////////////////////////////////

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	cP:createPath(str varname, str a, str b)
){
	printError("called rule create path to be put to variable <varname>");
    Graph[Coordinates] g = getGraph(artifact.currentState);
	
	if(a notin artifact.variables){ 
		artifact.errors += [variableUndefined(a, cP@location)];
		return artifact;
	}else if(b notin artifact.variables){
		artifact.errors += [variableUndefined(b, cP@location)];
		return artifact;
	}
	Coordinates pointA = min(artifact.variables[a]);
	Coordinates pointB = min(artifact.variables[b]);
	
	list[Coordinates] shortestPath = shortestPathPair(g, pointA, pointB);
	
    if(shortestPath == []){
    	printError("There is no viable path from <a> to <b> (graphname <varname>)");
    	artifact.errors += [noPath(a, b, varname, cP@location)];
    }else{
    	printError("Adding graph named <varname>");
    	artifact.graphs[varname] = path(pointA, pointB, shortestPath);
    }
	return artifact;
}

//////////////////////////////////////////////////////////////////////////////////
// Constraint calls
//////////////////////////////////////////////////////////////////////////////////

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	activateConstraint(str name)
){	
	//To implement
	return artifact;
}

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
	Coordinates locOnMap = <0,0>;
	
	if(varname in artifact.variables){ 
		set[Coordinates] affectedArea = artifact.variables[varname];
		set[Coordinates] toSubstract = {};

		if(varname in artifact.graphs)
			toSubstract = toSet(artifact.graphs[varname].path);
		else if(varname in artifact.variables)
			toSubstract = artifact.variables[varname];
		else{
			printError("Variable |<varname>| doesnt exist");
			artifact.errors += [variableDoesntExist(varname, callLoc)];
			return <artifact, modifiedArea, <0,0>>;
		} 
		println("area to substract <toSubstract>");
		
		// Normalise based on the current offset
		affectedArea = substractOffset(affectedArea - toSubstract, offset);
		//
		<locOnMap, modifiedArea> =
			translateCoordinatesToTilemap(affectedArea, \map);
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


