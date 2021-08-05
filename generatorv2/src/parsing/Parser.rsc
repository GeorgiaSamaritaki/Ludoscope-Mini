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

import util::Math;
import utility::TileMap;

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
	println("System Message: Parsed and checked");
	
	arbSeed(artifact.options.randomseed);
	ExecutionArtifact newArtifact = executeProject(artifact);
	
	if(newArtifact.errors != []){
		println("There were errors found while executing the project");
	}else{
		println("~~~~~~~~~Output~~~~~~~~~");
		printTileMap(newArtifact.output);
	}
}

