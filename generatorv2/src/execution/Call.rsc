module execution::Call

import List;
import Set;
import IO;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import execution::DataStructures;
import execution::Matching;

import parsing::DataStructures;
import parsing::AST;


public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	rulename(str name)
){
	println("called rule <name>");
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

	return executeCall(artifact,\module,graphname,g);
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	str graphname,
	createPath(str a, str b)
){
	println("here");
    Graph[Coordinates] g = getGraph(artifact.currentState);

	list[Coordinates] shortestPath = shortestPathInGraph(g, a, b, artifact.currentState);
	
    if(shortestPath == []) 
    	printError("There is no viable path from <a> to <b> (graphname <graphname>)");
    else{
    	artifact.graphs[graphname] = path(a, b, shortestPath);
    }
	return artifact;
}


