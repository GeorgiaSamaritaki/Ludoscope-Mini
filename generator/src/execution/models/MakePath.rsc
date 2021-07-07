//////////////////////////////////////////////////////////////////////////////
//
// 
// @brief        
// @contributor  
// @date         
//
//////////////////////////////////////////////////////////////////////////////

module execution::models::MakePath

import utility::TileMap;
import analysis::graphs::Graph;

import parsing::DataStructures;
import execution::DataStructures;
import execution::instructions::Matching;

public ExecutionArtifact createModel
(   ExecutionArtifact artifact, 
	LudoscopeModule \module, 
	makePath(str pointA, str pointB))
{
	//println(artifact);
	//
	//println(\module);
	println("in create model");
	return artifact;
}
