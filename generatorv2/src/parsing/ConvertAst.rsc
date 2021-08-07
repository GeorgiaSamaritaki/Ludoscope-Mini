module parsing::ConvertAst

import parsing::AST;
import parsing::DataStructures;

import IO;
import List;
public LudoscopeProject transformPipeline(Pipeline project){

	AlphabetMap alphabet = getAlphabetMap(project.alphabet.symbols);
	Options options = project.options;
	list[LudoscopeModule] modules = getModules(project.modules); 

	return ludoscopeProject(alphabet, options, modules, []);
}

private AlphabetMap getAlphabetMap(list[SymbolInfo] symbols){
	AlphabetMap alphMap = ();
	
	for(SymbolInfo si <- symbols)
		alphMap[si.abbreviation] = alphabetEntry(si.name.val,si.color);
		
	return alphMap;
} 

private list[LudoscopeModule] getModules(list[Module] modules){
	list[LudoscopeModule] ldModules = [];
	
	visit (modules){
		case modul(Name name, 
			 		Rules rules,
			 		Recipe recipe,
			 		list[Constraint] constraints) :
		{	
			RuleMap rulemap = getRules(rules.rules);
			RecipeList recipe =  checkRecipeList(recipe.calls, rulemap);
			ldModules += ludoscopeModule(name.val,
									   rulemap,
									   recipe,
									   constraints);
		}
	}
	return ldModules;
}

private RuleMap getRules(list[Rule] rules){
	RuleMap ruleMap = ();
	
	for(Rule r <- rules){
		TileMap lhs = patternToTilemap(r.leftHand.patterns),
				rhs = patternToTilemap(r.rightHand.patterns);
		if(!areSameDimensions(lhs,rhs)) 
			println("Error: Incorrect size length lhs rhs for rule <r.name> \n <lhs> \n <rhs> ");
		ruleMap[r.name.val] = ludoscopeRule(lhs,rhs);
	}
			
	return ruleMap;
}

private RecipeList checkRecipeList(RecipeList calls, RuleMap rules){
	visit (calls){
		case rulename(str name) : 
			if(name notin rules) 
					println("Error: Rule <name> specified in recipe
						does not exist in rules");
	}
	return calls;
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

private bool areSameDimensions(list[list[str]] lista, list[list[str]] listb){
	return all(int i <- [0 .. size(lista)], size(lista[i]) == size(listb[i])) && size(lista) == size(listb);	
}







