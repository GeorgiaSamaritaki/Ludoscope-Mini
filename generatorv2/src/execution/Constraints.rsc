module execution::Constraints

import IO;
import List;

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
		if(c.typ != onexit())
			checkConstraint(artifact, c, c.typ);
	}
	
	return artifact;
}

public ExecutionArtifact checkExitConstraints(
	ExecutionArtifact artifact, 
	list[Constraint] constraints
){
	for(c <-constraints){
		if(c.typ == onexit())
			checkConstraint(artifact, c, c.typ);
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
				}
			}
		}
	}
	return artifact;
}

private ExecutionArtifact checkPath(str name, ExecutionArtifact artifact, bool resolvable){
	HistoryEntry lastEntry = last(artifact.history);
	Graph g = artifact.graphs[name];
	
	list[Coordinates] intersection = lastEntry.coordinates & g.path;
	println("got here with intersection <intersection>");
	println("entry <lastEntry.ruleName>");
	println("path <g.path>");
	println("previous changes <lastEntry.coordinates>");
	if(intersection != []){
		//path is broken, try to see if there is another graph
		list[Coordinates] newPath = getPath(artifact.output, g.from, g.to);
		if(newPath == []){
			printError("<lastEntry.ruleName> in module <lastEntry.moduleName> destoyed path:<name>");
			
			if(resolvable){
				printSM("Trying to fix path...");
				for(c <- intersection)
					artifact.output = changeTile("f", c, artifact.output);
	
			}else{
				printSM("Constraint non resolvable exiting.");
				artifact.errors += ["exit"];
			}
			
			
		}else 
			artifact.graphs[name].path = newPath;
	}
	return artifact;
}







