//////////////////////////////////////////////////////////////////////////////
//
// Syntax for .mdl files.
// @brief        This files contains the syntax needed for parsing .mdl files.
//							 
// @contributor  
// @date         
//
//////////////////////////////////////////////////////////////////////////////

module parsing::languages::model::Syntax

import ParseTree;

//////////////////////////////////////////////////////////////////////////////
// Parser Rules
////////////////////////////////////////////////////////////////////////////// 

start syntax Model
  = model: Commands*;
  
syntax Commands
  = makePath: "MakePath" "(" String String ")" ;

syntax String
  = @category="String" "\"" STRING "\"";
  
//////////////////////////////////////////////////////////////////////////////
// Lexer Rules
//////////////////////////////////////////////////////////////////////////////

lexical NAME
  = @category="Name" ([a-zA-Z_$*] [a-zA-Z0-9_$*]* !>> [a-zA-Z0-9_$*]) \ Keyword;

lexical STRING
  = ![\"]*;
  
lexical COMMENTED
	= "//";

//////////////////////////////////////////////////////////////////////////////
// Layout
////////////////////////////////////////////////////////////////////////////// 

layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ : ,];

lexical LAYOUT
  = [\t-\n \r \ : ,];
 
keyword Keyword
  = "MakePath";
  
//////////////////////////////////////////////////////////////////////////////
// API
//////////////////////////////////////////////////////////////////////////////
  
public start[Model] parseModel(loc file) = 
  parse(#start[Model], file);
  
public start[Model] parseModel(str input, loc location) 
{ 
	return parse(#start[Model], input, location); 
}