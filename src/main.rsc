module Main

// import util::IDE;
// import vis::Figure;
import util::LanguageServer;
import util::IDEServices;
import util::Reflective;
import IO;

import parsing::Parser;
import parsing::Syntax;
import parsing::AST;

public str LDName = "Ludoscope_mini";  //language name
public str LDExtension  = "lm" ;           //file extension
public str LDMainModule  = "Main" ;    
PathConfig LDpcfg = pathConfig(srcs=[|project://ludoscope-mini/src|]);

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
	registerLanguage(
		language(
			LDpcfg, LDName, LDExtension, LDMainModule, LD_parse)
			);
	
	// LD_contributions = {STYLE};
	
	// registerContributions(LD_NAME, LD_contributions);
	// registerContributions(LD_NAME, menuItems);
	println("IDE loaded.");
}

     

