module execution::Call

import IO;
import List;

import parsing::DataStructures;
import parsing::AST;
import execution::DataStructures;
import execution::Matching;

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	rulename(str name)
){
	println("rule <name>");
	LudoscopeRule rule = \module.rules[name];
	
	//Find if the pattern matches
	list[Coordinates] matches = 
		findPatternInGrid(artifact.currentState, rule.lhs);
	
	if(isEmpty(matches)) {
		artifact.errors += ["No matches found for rule <name> in tilemap"];
		return artifact;
	}
	
	//Replace the right hand on the tilemap
	Coordinates match = getOneFrom(matches); //defined by the arbSeed function
	artifact.output = replacePattern(artifact.currentState, rule.rhs, match);
	
	artifact.history += [entry(
		artifact.currentState,
		artifact.output,
		match,
		\module.name, 
		name)];
	
	return artifact;
}

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	createGraph(CreateGraph graph)
){
	println("createGraph");
	
	return artifact;
}
