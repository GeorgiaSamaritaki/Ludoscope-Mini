module errors::Parsing

data ParsingError
	= imploding(loc fileLocation)
	| fileNotFound(loc fileLocation)
	| duplicateAlphabetEntry(str abbreviation, loc fileLocation)
	| duplicateRuleDefinition(str rulename, loc fileLocation)
	| undefinedCharacterInRule(str c, str rulename, loc fileLocation)
	| parsing(loc fileLocation)
	| ambiguity(loc fileLocation, str usedSyntax)
	| extension(loc fileLocation)
	| mapType(str mapType, loc fileLocation)
	| mapSize(int size, int symbols, loc fileLocation)
	| rightAndLeftHandSize(int leftWidth, int leftHeight, 
		int rightWidth, int rightHeight, loc fileLocation)
	| propertyName(str propertyName, loc fileLocation)
	| nonExistentRule(str ruleName, loc fileLocation)
	| nameType(str expectedType, str foundType, loc fileLocation);
	
str errorToString(parsing(loc fileLocation))
{
	return "Parsing error:
		\n Loc: <fileLocation>
		\n File: <fileLocation.path>
		\n Line: <fileLocation.end.line>";
}

str errorToString(ambiguity(loc fileLocation, str usedSyntax))
{
	return "Parsing error: ambiguity found while parsing.
		Syntax: <usedSyntax>
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.end.line>";
}

str errorToString(imploding(loc fileLocation))
{
	return "Parsing error: could not implode the parsing tree to
		the AST.
		Loc: <fileLocation>
		File: <fileLocation.path>";
}

str errorToString(fileNotFound(loc fileLocation))
{
	return "Input error: could not find the following file: 
		<fileLocation.path>";
}

str errorToString(duplicateAlphabetEntry(str abbreviation, loc fileLocation))
{
	return "Parsing error: Character <abbreviation> is already defined in Alphabet: <fileLocation>";
}

str errorToString(duplicateRuleDefinition(str rulename, loc fileLocation)){
	return "Parsing error: Rule <rulename> is already defined in this module: <fileLocation>";
}

str errorToString(undefinedCharacterInRule(str c, str rulename, loc fileLocation))
{
	return "Parsing error: Character \"<c>\" in rule \"<rulename>\" is not defined in the Alphabet: 
		<fileLocation.path>";
}


str errorToString(extension(loc fileLocation))
{
		return "Input error: could not parse <fileLocation>, because 
			the extension \".<fileLocation.extension>\" is not supported by LL.";
}

str errorToString(mapType(str mapType, loc fileLocation))
{
	return "Type error: \'<mapType>\' maps are not supported by LL
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.begin.line>";
}

str errorToString(mapSize(int size, int symbols, loc fileLocation))
{
	return "Error: the declared size of the map (<size>) does not match with
		the amount of symbols that follow (<symbols>).
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.end.line>";
}

str errorToString(rightAndLeftHandSize(int leftWidth, int leftHeight, 
		int rightWidth, int rightHeight, loc fileLocation))
{
	return "Error: the dimensions of the left hand (<leftWidth>, <leftHeight>) 
	do not match with	the dimensions of the right hand (<rightWidth>, <rightHeight>).
		\n Loc: <fileLocation>
		\n File: <fileLocation.path>
		\n Line: <fileLocation.end.line>";
}

str errorToString(propertyName(str propertyName, loc fileLocation))
{
	return "Error: the identifier \"<propertyName>\" used in defining a property 
	cannot be located in the syntax Tree.
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.begin.line>";
}

str errorToString(nonExistentRule(str ruleName, loc fileLocation))
{
	return "Error: Rule <ruleName> does not exist in rules specified in recipe 
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.begin.line>";
}


str errorToString(nameType(str expectedType, str foundType, loc fileLocation))
{
	return "Error: A name referenced to a <foundType>, while a <expectedType> name was expected.
		Loc: <fileLocation>
		File: <fileLocation.path>
		Line: <fileLocation.begin.line>";
}

