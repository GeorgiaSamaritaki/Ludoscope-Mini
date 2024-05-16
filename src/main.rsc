module Main

// import util::IDE;
// import vis::Figure;
import util::LanguageServer; 
import util::Reflective;
import ParseTree;
import IO;

import parsing::Parser;
import parsing::Syntax;
import parsing::AST;
import parsing::Outliner;

public str LDName = "LudoscopeMini";  //language name
public str LDExtension  = "lm" ;           //file extension
public str LDMainModule  = "Main" ;    

// Contribution STYLE =
//   categories
//   (
//     (
//       "Name" : {bold()},
//       "String" : {foregroundColor(color("purple"))},
//       "Boolean" : {foregroundColor(color("DarkRed"))},
//       "ColorCode" : {foregroundColor(color("Violet"))},
//       "Character" :{foregroundColor(color("dimgray"))},
//       "ConstraintKeywords" :{foregroundColor(color("Olive"))},
//       "Integer" : {foregroundColor(color("orange")), bold()}
//    	)
//  	);

public void main(){
 	// set[Contribution] menuItems =
	//   {	STYLE, popup
	//     (
	//       menu(
	//         "Lm: basic functions",
	//         [ action("Parse", parseProject),
	//           action("Execute project", runProject)
	//           //action("Execute and save result", executeProjectToFile)
	//         ]
	//       )
	//     )
	// };
	// registerLanguage(
	// 	language(
	// 		parsing::Outliner::LDpcfg, LDName, LDExtension, LDMainModule, LDContributions)
	// 		);
	 
	// LD_contributions = {STYLE};
	
	// registerContributions(LD_NAME, LD_contributions);
	// registerContributions(LD_NAME, menuItems);
	println("IDE loaded.");
}

     

