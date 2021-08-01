module parsing::Parser

import IO;
import ParseTree;
import String;

import parsing::AST;
import parsing::DataStructures;
import errors::Parsing;
import parsing::ConvertAst;
import parsing::Syntax;

import execution::Execution;
import execution::DataStructures;

public void parseProject(Tree tree, loc projectFile){
	println("Parse is called on: <projectFile>");
    AbstractPipeline project = implodePipeline(tree);
}
	
private LudoscopeProject parseAndCheck(Tree tree){
	AbstractPipeline project = implodePipeline(tree);
	
	LudoscopeProject artifact = transformPipeline(project);
	//artifact = checkTransformationArtifact(artifact);
	return artifact;	
} 

public void runProject(Tree tree, loc projectFile){
	LudoscopeProject artifact = parseAndCheck(tree);
	println("parsed and checked");
		
	ExecutionArtifact newArtifact = executeProject(artifact);
	//iprintln(newArtifact.output);
	//return;
	//}
	//if (newArtifact.errors == []){
	//else{ 
	//errors = newArtifact.errors;
	//
	//
	//println("There were errors found while parsing the project:");
	//for (ParsingError error <- errors)
	//	println(errorToString(error));
	//}
}
