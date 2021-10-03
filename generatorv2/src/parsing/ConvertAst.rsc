module parsing::ConvertAst

import parsing::AST;
import parsing::DataStructures;
import errors::Parsing;

import IO;
import List;
public TransformationArtifact transformPipeline(Pipeline project){
	TransformationArtifact artifact = transformationArtifact(
		ludoscopeProject(
			getAlphabetMap(project.alphabet.symbols),
			project.options,
			[], 
			[]
		),
			[]
	);
	
	artifact = getModules(project, artifact); 
	//ludoscopeProject(alphabet, options, modules, []);
	return artifact;
}

private AlphabetMap getAlphabetMap(list[SymbolInfo] symbols){
	AlphabetMap alphMap = ();
	
	for(SymbolInfo si <- symbols)
		alphMap[si.abbreviation] = alphabetEntry(si.name.val,si.color);
		
	return alphMap;
} 

//Unfortunately this became overly complex in order to handle errors
private TransformationArtifact getModules(Pipeline project, 
										 TransformationArtifact artifact ){
	list[Module] modules = project.modules;
	list[LudoscopeModule] ldModules = [];
	
	visit (modules){
		case modul(Name name, 
			 		Rules rules,
			 		Recipe recipe,
			 		list[Constraint] constraints) :
		{	
			tuple[RuleMap ruleMap, 
				  TransformationArtifact artifact] ruleTuple = 
				  			getRules(rules.rules, artifact);
			tuple[RecipeList recipe, 
				  TransformationArtifact artifact] recipeTuple= 
				  			checkRecipeList(recipe, ruleTuple.ruleMap, ruleTuple.artifact);
			ldModules += ludoscopeModule(name.val,
									   ruleTuple.ruleMap,
									   recipeTuple.recipe,
									   constraints);
			artifact = recipeTuple.artifact;
		}
	}
	artifact.project.modules = ldModules;
	return artifact;
}

private tuple[RuleMap, TransformationArtifact] 
				getRules(list[Rule] rules, TransformationArtifact artifact){
	RuleMap ruleMap = ();
	
	for(Rule r <- rules){
		TileMap lhs = patternToTilemap(r.leftHand.patterns),
				rhs = patternToTilemap(r.rightHand.patterns);
		if(!areSameDimensions(lhs,rhs)){ 
			//println("Error: Incorrect size length lhs rhs for rule <r.name> \n <lhs> \n <rhs> ");
			artifact.error +=[rightAndLeftHandSize(size(lhs), 
							size(lhs[0]), 
							size(rhs), 
							size(rhs[0]), 
							r@location)];
		}
		ruleMap[r.name.val] = ludoscopeRule(lhs,rhs);
	}
			
	return <ruleMap, artifact>;
}

private tuple[RecipeList, TransformationArtifact] 
					checkRecipeList(Recipe recipe, 
								   RuleMap rules,
								   TransformationArtifact artifact){
    RecipeList calls = recipe.calls;
	visit (calls){
		case rulename(str name) : 
			if(name notin rules){
				println("Error: Rule <name> specified in recipe does not exist in rules ");
				artifact.errors += [nonExistentRule(name, recipe@location)];
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
	return all(int i <- [0 .. size(listA)], size(listA[i]) == size(listB[i])) && size(listA) == size(listB);	
}







