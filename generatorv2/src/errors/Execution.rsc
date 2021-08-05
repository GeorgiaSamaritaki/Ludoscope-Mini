//////////////////////////////////////////////////////////////////////////////
//
// Execution errors
// @brief        This file contains data types for execution errors.
// @contributor  Quinten Heijn - samuel.heijn@gmail.com - UvA
// @date         01-05-2018
//
//////////////////////////////////////////////////////////////////////////////

module errors::Execution

import IO;

data ExecutionError
	= moduleConnection(list[str] moduleNames);
	
public void printError(str errormessage){
	println("Error message: <errormessage>");
}

public void printSM(str systemmessage){
	println("System Message: <systemmessage>");
}