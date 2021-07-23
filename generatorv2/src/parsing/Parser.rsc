module parsing::Parser

import IO;
import Exception;
import List;
import ParseTree;
import String;

import parsing::AST;
import parsing::DataStructures;
import errors::Parsing;
import parsing::ConvertAst;
import parsing::Syntax;


public void parseProject(Tree tree, loc projectFile){
	println("Parse is called on: <projectFile>");
    AbstractPipeline project = parsePipelineToAST(projectFile);
    
    println(project);
    println("ok!");
}

public SyntaxTree parseProject1(loc file, SyntaxTree syntaxTree){
	try 
	{	
		switch (file.extension)
		{
			case "lm" : syntaxTree.pipeline = [parsePipelineToAST(file)];
			default : syntaxTree.errors += [errors::Parsing::extension(file)];
		}
	}
	catch ParseError(loc errorLocation):{
		println("caught error1 :<errorLocation>");
		syntaxTree.errors += [errors::Parsing::parsing(errorLocation)];
	}
	catch Ambiguity(loc errorLocation, str usedSyntax, str parsedText):{
		println("caught error2 : <parsedText>");
		syntaxTree.errors += [errors::Parsing::ambiguity(errorLocation, usedSyntax)];
	}
	catch IllegalArgument(value v, str message):{
		println("caught error3: \"<message>\" ");
		syntaxTree.errors += [errors::Parsing::imploding(file)];
	}
	return syntaxTree;
}

	
	
public TransformationArtifact parseAndCheck(loc projectFile){
	SyntaxTree syntaxTree = syntaxTree([],[]);
	syntaxTree = parseProject1(projectFile, syntaxTree);
	
	TransformationArtifact artifact = transformationArtifact(undefinedProject(), []);
	if (size(syntaxTree.errors) == 0){
		artifact = transformSyntaxTree(syntaxTree);
		//artifact = checkTransformationArtifact(artifact);
	}else
		artifact.errors = syntaxTree.errors;
	return artifact;
	
}


public void executeProject(Tree tree, loc projectFile){
	TransformationArtifact artifact = parseAndCheck(projectFile);
	println("parsed and checked");
	//list[ParsingError] errors = [];
	//if (artifact.errors == []){
	//
	//	ExecutionArtifact newArtifact = executeProject(artifact.pipeline);
	//	if (newArtifact.errors == []){
	//		iprintln(newArtifact.output);
	//		return;
	//	}else errors = newArtifact.errors;
	//
	//}else errors = artifact.errors;
	//
	//println("There were errors found while parsing the project:");
	//for (ParsingError error <- errors)
	//	println(errorToString(error));
	
}
