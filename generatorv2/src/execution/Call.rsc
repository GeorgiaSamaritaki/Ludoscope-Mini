module execution::Call

import List;
import Set;

import errors::Exection;
import utility::TileMap;

import parsing::DataStructures;
import parsing::AST;
import execution::DataStructures;
import execution::Matching;

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	rulename(str name)
){
	LudoscopeRule rule = \module.rules[name];
	
	//Find if the pattern matches
	set[Coordinates] matches = 
		findPatternInGrid(artifact.currentState, rule.lhs);
	
	
	if(isEmpty(matches)) {
		printError("No matches found for rule <name> in tilemap");
		return artifact;
	}
	
	//Replace the right hand on the tilemap
	Coordinates match = getOneFrom(matches); //defined by the arbSeed function
	artifact.output = replacePattern(artifact.currentState, rule.rhs, match);
	
	artifact.history += [ entry(
		artifact.currentState,
		artifact.output,
		getAllCoordinates(match,patternSize(rule.lhs)), //every tile affected
		\module.name, 
		name)];
	
	return artifact;
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	createGraph(str graphname, CreateGraph g)
){
	list[Coordinates] path = getPath(artifact.currentState,g.a,g.b);
	
    if(path == []) 
    	printError("There is no viable path from <g.a> to <g.b> (graphname <graphname>)");
    else{
    	artifact.graphs[graphname] = graph(g.a, g.b, path);
    }
	return artifact;
}
