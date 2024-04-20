//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file containts the evaluation of constraints 
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module execution::Constraints

import IO;
import List;
import Set;
import analysis::graphs::Graph;

import utility::TileMap;
import errors::Execution;

import parsing::DataStructures;
import parsing::AST;

import execution::DataStructures;
import execution::Handlers;


public ExecutionArtifact checkNonExitConstraints(
	ExecutionArtifact artifact, 
	list[Constraint] constraints
){
	for(c <- constraints, !c := empty() && c.typ != onexit()){
		printError("Checking Constraint <c.name>");
		artifact = checkConstraint(artifact, c, c.typ);
		if(artifact.errors!=[]) break;
	}
	return artifact;
}

public ExecutionArtifact checkExitConstraints(
	ExecutionArtifact artifact, 
	list[Constraint] constraints
){
	for(c <- constraints, !c := empty() && c.typ == onexit()){
		printError("Checking Constraint <c.name>");
		artifact = checkConstraint(artifact, c, c.typ);
		if(artifact.errors!=[]) break;
	}
	
	return artifact;
}

/////////////////////////////////////////////////////////////////////////////////
// Constraint Types
/////////////////////////////////////////////////////////////////////////////////
private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	onexit()
){
	Value v;
	<artifact, v> = eval(c.exp, artifact); 
	if(artifact.errors != []) return artifact;
	
	visit(v){
		case boolean(bool b):{
			if(!b){
				printError("Constraint non resolvable exiting.");
				artifact.errors += [constraintNotMet(c.name, c@location)];
			} 
			return artifact;
		}
		case integer(_):{ 
			artifact.errors += [constraintEval(c.name, c@location)];
			return artifact;
		}
	}
	artifact.errors += [runtimeMachineError()];
		
	return artifact;
}

private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	r:resolvable()
){ //FIXME: make it pretty
	int i = 0;
	Value v;
	<artifact, v> = eval(c.exp, artifact); 
	if(artifact.errors != []) return artifact;

	if(v is boolean){
		while(!v.boolean && //while the condition is not met 
			  i < execution::Handlers::maxHandlerCalls){ //and the max call limit hasnt been reached
			println("calling handlerdler <i>");
			
			artifact = callHandler(c.name, artifact);
			<artifact, v> = eval(c.exp, artifact); 
			if(artifact.errors != []) return artifact;
			i+=1;
		}
		if(!v.boolean) //handler failed to fix it
			artifact.errors += [maxHandlerCallsReached(c.name,r@location)];
			
	}else if(v is integer){ 
		artifact.errors += [constraintEval(c.name, c@location)];
		return artifact;
	}else artifact.errors += [runtimeMachineError()];
	
	return artifact;
}

private ExecutionArtifact checkConstraint(
	ExecutionArtifact artifact, 
	Constraint c,
	nonresolvable()
){
	Value v;
	<artifact, v> = eval(c.exp, artifact); 
	if(artifact.errors != []) return artifact;
	
	visit(v){
		case boolean(bool b):{
			if(!b){
				printError("Constraint non resolvable exiting.");
				artifact.errors += [constraintNotMet(c.name, c@location)];
			}else 
				return artifact;
		}
		case integer(_):{ 
			artifact.errors += [constraintEval(c.name, c@location)];
			return artifact;
		}
	}
	artifact.errors += [runtimeMachineError()];
		
	return artifact;
}

/////////////////////////////////////////////////////////////////////////////////
// Evaluation functions
/////////////////////////////////////////////////////////////////////////////////

private tuple[ExecutionArtifact, Value] eval(Expression exp, ExecutionArtifact artifact){
	visit(exp){
		case e_eq(Expression lhs, Expression rhs):{
			Value l,r;
			<artifact, l> = eval(lhs, artifact);
			<artifact, r> = eval(rhs, artifact);
			if((r is boolean && l is boolean) ||
				(r is integer && l is integer))
				return <artifact, evalEq(l, r)>;
			else{
				return <artifact, integer(-1)>;
			}
		}
	}
	//I separated the visits cause it never went to the e_eq for some reason
	visit(exp){
		case e_val(Value val):{
			return <artifact, val>;
		}
		case func(FunctionType ft, Name varName):{
			Value f; 
			<artifact, f> = evalFunc(ft, varName.val, artifact);
			
			return <artifact, f>;
		}
		case incl(str var1, str var2): {
			if(var1 notin artifact.variables){
				printError("Variable <var1> is not defined");
				artifact.errors += [variableUndefined(var1, exp@location)];
			}else if(var2 notin artifact.variables){
				printError("Variable <var2> is not defined");
				artifact.errors += [variableUndefined(var2, exp@location)];
			}else 
				return <artifact, evalIncl(var1, var2, artifact)>;
		}
		
	}
	printError("Non implemented expression <exp>");
	artifact.errors += [notImplemented(exp@location)];

	return <artifact, integer(1)>;
}

private Value evalEq(integer(int a), integer(int b)){
	return boolean(a==b);
}

private Value evalEq(boolean(bool a), boolean(bool b)){
	return boolean(a==b);
}


private Value evalIncl(str var1, str var2, ExecutionArtifact artifact){
	set[Coordinates] var1coords = artifact.variables[var1],
					var2coords = artifact.variables[var2];
	return boolean(var1coords <= fillInCoordinates(var2coords));
}

private tuple[ExecutionArtifact, Value] evalFunc(count(), str name, ExecutionArtifact artifact){
	return <artifact, integer(countOccurences(name, artifact.output))>;
}

private tuple[ExecutionArtifact, Value] evalFunc(exists(), str name, ExecutionArtifact artifact){
	return <artifact, boolean(inMap(name, artifact.output))>;
}

private tuple[ExecutionArtifact, Value] evalFunc(intact(), str name, ExecutionArtifact artifact){
	if(name notin artifact.graphs) return <artifact, boolean(true)>;
	Path p = artifact.graphs[name];
	
	list[Coordinates] intersection = [];
	
	//if(isEmpty(artifact.history)) intersection = [<0,0>];
	//else intersection = toList(last(artifact.history).coordinates) & p.path;
	//
	//if(intersection != []){
		//path is broken, Recompute graph
		Graph[Coordinates] newGraph = getGraph(artifact.output);
		list[Coordinates] newPath = shortestPathPair(newGraph, p.from, p.to);
		
		//println("new path <newPath>");
		if(newPath == []){
			 //printError("<lastEntry.ruleName> in module <lastEntry.moduleName> destoyed path <name>");
			//errors +=
			return <artifact, boolean(false)>;
		}else 
			artifact.graphs[name].path = newPath;
	//}
	return <artifact, boolean(true)>;
}

			//if(resolvable){
			//	HistoryEntry newEntry = entry(
			//								artifact.output,
			//								[],
			//								intersection,
			//								"Repair",
			//								"Path");
			//	printSM("Trying to fix path...");
			//	for(c <- intersection){
			//		artifact.output = changeTile("f", c, artifact.output);
			//	}
			//	newEntry.after = artifact.output;
			//	artifact.history += [newEntry];
			//}else{
			//	printSM("Constraint non resolvable exiting.");
			//	artifact.errors += [constraintNotMet(name)];
			//}
			//






