//////////////////////////////////////////////////////////////////////////////
//
// Transform Model
// @brief        Functions that move the relevant content from the AST to
//							 a new ADT declared in DataStructures.rsc.
// @contributor  
// @date         
//
//////////////////////////////////////////////////////////////////////////////

module parsing::transformations::Model

import parsing::Parser;
import parsing::DataStructures;
import parsing::transformations::Utility;
import parsing::languages::model::AST;

public TransformationArtifact transformModels(TransformationArtifact artifact, 
	SyntaxTree syntaxTree)
{
	for (str modelName <- syntaxTree.models)
	{
		int moduleIndex = findModuleIndex(modelName, artifact);
		
		for (Model m<- syntaxTree.recipes[modelName].instructions)
		{
				artifact.project.modules[moduleIndex].model = m;
		}
	}
	return artifact;
}
