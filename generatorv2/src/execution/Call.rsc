module execution::Call

import IO;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

public ExecutionArtifact executeCall(
	ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	rulename(str name)
){
	Rule rule = \module.rules[ruleName];
	println("rule <name>");
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