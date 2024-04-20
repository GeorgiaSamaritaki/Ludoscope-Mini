//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file filters the data impoded from the .lm files. 
//			In the process of filtering it generated parsing errors.
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module parsing::ConvertAst

import parsing::AST;
import parsing::DataStructures;
import errors::Parsing;
import utility::TileMap;

import IO;
import List;


public TransformationArtifact transformPipeline(Pipeline project){
	TransformationArtifact artifact = getEmptyTransformationArtifact();
	
	artifact = getAlphabetMap(project.alphabet.symbols, artifact);
	artifact = getConstraints(project.constraints, artifact);
	artifact.project.options = project.options;
	artifact = getHandlers(project.handlers, artifact);
	
	
	artifact = getModules(project, artifact); 
	//ludoscopeProject(alphabet, options, modules, []);
	return artifact;
}

private TransformationArtifact getAlphabetMap(list[SymbolInfo] symbols, 
								   TransformationArtifact artifact){
	AlphabetMap alphMap = ();
	
	for(SymbolInfo si <- symbols)
		if(si.abbreviation notin alphMap)
			alphMap[si.abbreviation] = alphabetEntry(si.name.val,si.color);
		else
			artifact.errors += [duplicateAlphabetEntry(si.abbreviation, si.src)];
	
	artifact.project.alphabet = alphMap;
	return artifact;
}

private TransformationArtifact getHandlers(list[Handler] handlers, 
								   TransformationArtifact artifact){
	HandlerMap hmap = ();
	
	for(Handler h <- handlers)
		if(h.name notin hmap)
			hmap[h.name] = h.hcalls;
		else
			artifact.errors += [duplicateHandlerDefinition(h.name, h.src)];
	
	artifact.project.handlers = hmap;
	return artifact;
} 
 

private TransformationArtifact getModules(Pipeline project, 
										 TransformationArtifact artifact){
	list[Module] modules = project.modules;
	list[LudoscopeModule] ldModules = [];
	
	visit (modules){
		case modul(Name name, 
			 		Rules rules,
			 		Recipe recipe,
			 		list[Constraint] constraints) :
		{	
			RuleMap ruleMap = ();
			RecipeList recipeList = [];
			
			<ruleMap, artifact> = getRules(rules.rules, artifact);
			if(artifact.errors != []) return artifact;
			
			<recipeList, artifact>  = checkRecipeList(recipe, ruleMap, artifact);
			if(artifact.errors != []) return artifact;
			
			constraints = [c | c <- constraints, c != empty()];
			//Probably needs some checking for constraints

			ldModules += ludoscopeModule(name.val,
									   ruleMap,
									   recipeList,
									   constraints);
		}
	}
	artifact.project.modules = ldModules;
	return artifact;
}

private tuple[RuleMap, TransformationArtifact] 
				getRules(list[Rule] rules, TransformationArtifact artifact){
	RuleMap ruleMap = ();
	
	for(Rule r <- rules){
		//Check if the two sides are the same dimensions
		TileMap lhs = patternToTilemap(r.leftHand.patterns),
				rhs = patternToTilemap(r.rightHand.patterns);
		// println("Checking rule <r.src>\n ");
		if(!areSameDimensions(lhs,rhs)){ 
			println("Error: Incorrect size length lhs rhs for rule <r.name> \n <lhs> \n <rhs> ");
			artifact.errors +=[rightAndLeftHandSize(size(lhs), 
							size(lhs[0]), 
							size(rhs), 
							size(rhs[0]), 
							r.src)];
		}
		//Check if the rule is already defined
		if(r.name.val in ruleMap){
			println("Error: Rule <r.name> is already defined");
			artifact.errors += [duplicateRuleDefinition(r.name.val, r.src)];
			return <(),artifact>;
		}else 
			ruleMap[r.name.val] = ludoscopeRule(lhs, rhs);
		
		//Check if all the characters used in rule are defined, can be turned off
		list[str] characters = dup(flatten(lhs + rhs));
		for(c <- characters) 
			if(c notin artifact.project.alphabet) 	
				artifact.errors += [undefinedCharacterInRule(c, r.name.val, r.src)];
	}
			
	return <ruleMap, artifact>;
}

private tuple[RecipeList, TransformationArtifact] 
					checkRecipeList(Recipe recipe, 
								   RuleMap rules,
								   TransformationArtifact artifact){
    RecipeList calls = recipe.calls;
	visit (calls){
		case c:call(str ruleName) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
		case c:assignCall(_, str ruleName) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
		case c:appendCall(_, str ruleName) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
		case c:callM(str ruleName,_) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
		case c:assignCallM(_, str ruleName,_) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
		case c:appendCallM(_, str ruleName,_) : 
			if(ruleName notin rules){
				println("Error: Rule <ruleName> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(ruleName, c.src)];
			}
	}
	return <calls, artifact>;
}

private TileMap patternToTilemap(list[str] pl){
	list[list[str]] tileMap = [];
	list[str] currentList = [];
	
	for(str c <- pl){
		if(c == ","){
			tileMap += [currentList];
			currentList = [];
		}else 
			currentList += c;
	}
	
	tileMap += [currentList];
	return tileMap;
}

private bool areSameDimensions(list[list[str]] listA, list[list[str]] listB){
	return size(listA) == size(listB) && all(int i <- [0 .. size(listA)], size(listA[i]) == size(listB[i]));	
}



private TransformationArtifact getConstraints (
	list[Constraint] constraints, 
	TransformationArtifact artifact){
	
	constraints = [c | c <- constraints, c != empty()];
	
	//for(c <- constraints){
	//	if(c.typ == count()){ ;
	//		
	//	}else if (c.typ == exists()){ ;
	//	
	//	}else if (c.typ == intact()){ ;
	//	
	//	}
	//}//ToDo implement
	
	artifact.project.constraints = constraints;
	return artifact;
}




