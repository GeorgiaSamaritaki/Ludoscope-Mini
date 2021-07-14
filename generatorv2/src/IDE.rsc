module IDE

import util::IDE;
import vis::Figure;
import ParseTree;
import IO;

import parsing::Syntax;

public str LD_NAME = "Ludoscope_mini";  //language name
public str LD_EXT  = "lm" ;           //file extension


Contribution STYLE =
  categories
  (
    (
      "Name" : {bold()},
      "String" : {foregroundColor(color("purple"))},
	  "Comment": {foregroundColor(color("dimgray")),bold()},
      "ColorCode" : {foregroundColor(color("Violet"))},
      "Boolean" : {foregroundColor(color("Black")), bold()}
   	)
 	);

public void main()
{
	registerLanguage(LD_NAME, LD_EXT, LD_parse);
	
	LD_contributions = {STYLE};
	
	registerContributions(LD_NAME, LD_contributions);
	println("IDE loaded.");
}


