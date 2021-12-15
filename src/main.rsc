module main

import util::IDE;
import vis::Figure;
import IO;

import parsing::Parser;
import parsing::Syntax;
import parsing::AST;

public str LD_NAME = "Ludoscope_mini";  //language name
public str LD_EXT  = "lm" ;           //file extension

Contribution STYLE =
  categories
  (
    (
      "Name" : {bold()},
      "String" : {foregroundColor(color("purple"))},
      "Boolean" : {foregroundColor(color("DarkRed"))},
      "ColorCode" : {foregroundColor(color("Violet"))},
      "Character" :{foregroundColor(color("dimgray"))},
      "ConstraintKeywords" :{foregroundColor(color("Olive"))},
      "Integer" : {foregroundColor(color("orange")), bold()}
   	)
 	);

public void main(){
 	set[Contribution] menuItems =
	  {	STYLE, popup
	    (
	      menu(
	        "Lm: basic functions",
	        [ action("Parse", parseProject),
	          action("Execute project", runProject)
	          //action("Execute and save result", executeProjectToFile)
	        ]
	      )
	    )
	};
	registerLanguage(LD_NAME, LD_EXT, LD_parse);
	
	LD_contributions = {STYLE};
	
	registerContributions(LD_NAME, LD_contributions);
	registerContributions(LD_NAME, menuItems);
	println("IDE loaded.");
}

     

