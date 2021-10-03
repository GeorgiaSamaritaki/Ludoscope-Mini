module execution::Constraints

import IO;
import List;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import parsing::DataStructures;
import execution::DataStructures;
import parsing::AST;

public ExecutionArtifact checkNonExitConstraints(
	ExecutionArtifact artifact, 
	list[Constraint] constraints
){
	for(c <-constraints){
		if(c.typ != onexit()){
			//println("Checking constraint <c.name>");
			artifact = checkConstraint(artifact, c, c.typ);
			//println("Finished checking constraint <c.name>");
		}
	}
	
	return artifact;
}

public ExecutionArtifact checkExitConstraints(
	ExecutionArtifact artifact, 
	list[Constraint] constraints
){
	for(c <-constraints){
		if(c.typ == onexit())
			artifact = checkConstraint(artifact, c, c.typ);
	}
	
	return artifact;
}

private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	onexit()
){
	
	visit(c.exp){
		case e_eq(Expression lhs, Expression rhs):{ //oversimplification of expressions
			visit(lhs.val){
				case char(str char):{
					list[Coordinates] ca = findInMap(artifact.output,char); 
					if(ca ==[]) printError("On exit constraint <c.name> not met");
				;}
			}
		}
	}
	return artifact;
}

private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	resolvable()
){
	visit(c.exp){
		case e_eq(Expression lhs, Expression rhs):{ //oversimplification of expressions
			if(lhs.val == path()){
				if("path" in artifact.graphs){	
					artifact = checkPath("path", artifact, true);
				}
			}
		}
	}
		
	return artifact;
}

private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	nonresolvable()
){
	
	visit(c.exp){
		case e_eq(Expression lhs, Expression rhs):{ //oversimplification of expressions
			if(lhs.val == path()){
				if("path" in artifact.graphs){	
					artifact = checkPath("path", artifact, false);
				printTileMap(artifact.output);
				}
			}
		}
	}
	return artifact;
}

private ExecutionArtifact checkPath(str name, ExecutionArtifact artifact, bool resolvable){
	HistoryEntry lastEntry = last(artifact.history);
	Path p = artifact.graphs[name];
	//println("check path <lastEntry.coordinates> path:<p.path>");
	list[Coordinates] intersection = lastEntry.coordinates & p.path;
	if(intersection != []){
		//path is broken, Recompute graph
		Graph[Coordinates] newGraph = getGraph(artifact.output);
		list[Coordinates] newPath = shortestPathInGraph(newGraph, p.from, p.to, artifact.output);
		//println("new path <newPath>");
		if(newPath == []){
			printError("<lastEntry.ruleName> in module <lastEntry.moduleName> destoyed path:<name>");
			
			if(resolvable){
				HistoryEntry newEntry = entry(
											artifact.output,
											[],
											intersection,
											"Repair",
											"Path");
				printSM("Trying to fix path...");
				for(c <- intersection){
					artifact.output = changeTile("f", c, artifact.output);
				}
				newEntry.after = artifact.output;
				artifact.history += [newEntry];
			}else{
				printSM("Constraint non resolvable exiting.");
				artifact.errors += ["exit"];
			}
			
			
		}else 
			artifact.graphs[name].path = newPath;
	}
	return artifact;
}







