module parsing::ConvertAst

import parsing::AST;
import parsing::DataStructures;

import IO;
public TransformationArtifact transformSyntaxTree(SyntaxTree syntaxTree)
{

	println("in transformsyntaxtree");

	//LudoscopeProject project = ludoscopeProject([], ());
	TransformationArtifact artifact = transformationArtifact(undefinedProject(), []);
	//
	//artifact = transformProject(artifact, syntaxTree);
	//artifact = transformAplhabets(artifact, syntaxTree);
	//artifact = transformGrammars(artifact, syntaxTree);
	//artifact = transformRecipes(artifact, syntaxTree);
	//artifact = transformModels(artifact, syntaxTree);
	//artifact = transformProperties(artifact, syntaxTree);
	//
	//artifact = addEmptyRecipes(artifact);
	
	return artifact;
}
