module execution::Call

import IO;
import List;
import Set;

import parsing::DataStructures;
import parsing::AST;
import execution::DataStructures;
import execution::Matching;
import utility::TileMap;

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	rulename(str name)
){
	println("rule <name>");
	LudoscopeRule rule = \module.rules[name];
	
	//Find if the pattern matches
	set[Coordinates] matches = 
		findPatternInGrid(artifact.currentState, rule.lhs);
	
	if(isEmpty(matches)) {
		artifact.errors += ["No matches found for rule <name> in tilemap"];
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
	createGraph(CreateGraph g)
){
	list[Coordinates] path = getPath(artifact.currentState,g.a,g.b);
	
	println("Path <path>");
    if(path == []) 
    	println("There is no viable path from <g.a> to <g.b>");
    else
    	artifact.graphs += [graph(g.a, g.b, path)];
    
	return artifact;
}











