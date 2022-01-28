module errors::Execution

import IO;

data ExecutionError
	= moduleConnection(list[str] moduleNames)
	| notImplemented(loc fileLocation)
	| notAppliableModifier(loc fileLocation)
	| couldNotApplyRule(str ruleName, loc fileLocation)
	| variableDoesntExist(str varname, loc fileLocation)
	| noPath(str a, str b, str graphname, loc fileLocation)
	| runtimeMachineError()
	| maxHandlerCallsReached(str handlerName, loc fileLocation)
	| constraintNotMet(str name, loc fileLocation)
	| constraintEval(str name, loc fileLocation)
	| variableUndefined(str name, loc fileLocation)
	| undefinedHandler(str name)
	| pathBroken(str ruleName, str moduleName, str graphname)
	;
	
public void printError(str errormessage){
	println("Debugger message: <errormessage>");
}

str errorToString(notImplemented(loc fileLocation)){
	return "Execution error: Not implemented
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.begin.line>";
}

str errorToString(runtimeMachineError()){
	return "Execution error: runtimeMachineError";
}

str errorToString(couldNotApplyRule(str ruleName, loc fileLocation)){
	return "Execution error: No matches found for rule <ruleName> in tilemap: 
	<fileLocation>";
}

str errorToString(variableDoesntExist(str varname, loc fileLocation)){
	return "Execution error: Variable <varname>	doesnt exist: <fileLocation>";
}

str errorToString(notAppliableModifier(loc fileLocation)){
	return "Execution error: Cant apply modifer at <fileLocation>";
}

str errorToString(noPath(str a, str b, str graphname, loc fileLocation)){
	return "Execution error: There is no viable path from <a> to <b> (graphname <graphname>): 
	<fileLocation>";
}

str errorToString(pathBroken(str ruleName, str moduleName, str graphname)){
	return "Execution error: <ruleName> in module <moduleName> destoyed path <graphname>";
}

str errorToString(constraintNotMet(str name, loc fileLocation)){
	return "Execution error: Constraint <name> could not be met:
	<fileLocation>";
}

str errorToString(constraintEval(str name, loc fileLocation)){
	return "Execution error: Constraint <name> could not be evaluated 
	<fileLocation> ";
}

str errorToString(variableUndefined(str name, loc fileLocation)){
	return "Execution error: Variable |<name>| is not defined
	<fileLocation>";
}

str errorToString(undefinedHandler(name)){
	return "Execution error: Handler |<name>| is not defined";
}

str errorToString(maxHandlerCallsReached(str handlerName, loc fileLocation)){
	return "Execution error: Max Handler Calls reached. Handler |<handlerName>| was unable to fix the issue
	<fileLocation>";	
}

public void printSM(str systemmessage){
	println("System Message: <systemmessage>");
}