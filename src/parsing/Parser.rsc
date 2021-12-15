//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This function contains the functions that are called to parse
//			and execute. They are used both from the main and from the IDE.
//			They also display the errors.
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module parsing::Parser

import IO;
import ParseTree;
import String;

import parsing::AST;
import parsing::DataStructures;
import parsing::ConvertAst;
import parsing::Syntax;

import execution::Execution;
import execution::DataStructures;

import util::Math;
import utility::TileMap;

import errors::Parsing;
import errors::Execution;

public void parseProject(Tree tree, loc projectFile){
	//println("Parse is called on: <projectFile>");
    AbstractPipeline project = implodePipeline(tree);
}
	
private TransformationArtifact parseAndCheck(Tree tree){
	AbstractPipeline project = implodePipeline(tree);
	
	TransformationArtifact artifact = transformPipeline(project);
	//artifact = checkTransformationArtifact(artifact);
	if (artifact.errors != []){
		println("There were errors found while parsing the project:");
		for (ParsingError error <- artifact.errors)
			println(errorToString(error));
	}
	return artifact;	
}

	
public ExecutionArtifact executeProjectAndCheck(TransformationArtifact artifact){
	if(artifact.errors != []) 
		return emptyExecutionArtifact();
		
	arbSeed(artifact.project.options.randomseed);
	ExecutionArtifact newArtifact = executeProject(artifact.project);
	
	if(newArtifact.errors != []){
		printSM("There were errors found while executing the project");
		for (ExecutionError error <- newArtifact.errors)
			println(errorToString(error));
	}
	printSM("Done Executing");
	return newArtifact;
}  

public TransformationArtifact parseProjectFromLoc(loc projectFile){
	AbstractPipeline project = implodePipeline(LD_parse(projectFile));
	TransformationArtifact artifact = transformPipeline(project);
	return artifact;	
} 

public void runProject(Tree tree, loc projectFile){
	TransformationArtifact artifact = parseAndCheck(tree);
	printSM("Parsed and checked");
	
	if(artifact.errors != []) return;
	
	arbSeed(artifact.project.options.randomseed);
	ExecutionArtifact newArtifact = executeProject(artifact.project);
	
	if(newArtifact.errors != []){
		printSM("There were errors found while executing the project");
		for (ExecutionError error <- newArtifact.errors)
			println(errorToString(error));
	}else{
		println("~~~~~~~~~Output~~~~~~~~~");
		printTileMap(newArtifact.output);
	}
}

