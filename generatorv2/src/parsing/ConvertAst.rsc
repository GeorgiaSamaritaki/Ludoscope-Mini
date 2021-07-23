module parsing::ConvertAst

import parsing::AST;
import parsing::DataStructures;

import IO;
public LudoscopeProject transformPipeline(Pipeline project){

	Alphabet alphabet = project.alphabet;
	Options options = project.options;
	list[LudoscopeModule] modules = getModules(project.modules); 

	return ludoscopeProject(alphabet, options, modules, []);
}

private list[LudoscopeModule] getModules(list[Module] modules){
	list[LudoscopeModule] ldModules = [];
	
	visit (modules){
		case modul(Name name, 
			 		Rules rules,
			 		Recipe recipe,
			 		list[Constraint] constraints) :
		{	
			ldModules += ludoscopeModule(name.val,
									   getRules(rules.rules),
									   recipe.calls,
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
		ruleMap[r.name.val] = ludoscopeRule(lhs,rhs);
	}
			
	return ruleMap;
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










