module IDE

import util::IDE;
import vis::Figure;
import ParseTree;
import IO;

import parsing::Syntax;
import parsing::AST;

public str LD_NAME = "Ludoscope_mini";  //language name
public str LD_EXT  = "lm" ;           //file extension

alias AbstractPipeline = parsing::AST::Pipeline;

Contribution STYLE =
  categories
  (
    (
      "Name" : {bold()},
      "String" : {foregroundColor(color("purple"))},
	  "Comment": {foregroundColor(color("dimgray")),bold()},
      "COLORCODE" : {foregroundColor(color("Violet"))},
      "Boolean" : {foregroundColor(color("Black")), bold()}
   	)
 	);

public void main(){
 	set[Contribution] menuItems =
	  {	STYLE, popup
	    (
	      menu(
	        "LL: basic functions",
	        [ action("Parse", parseProject)
	          //action("Execute project", executeProject),
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

public void parseProject(Tree tree, loc projectFile){
	println("project file <projectFile>");
    AbstractPipeline project = parsePipelineToAST(projectFile);
    
    println(project);
    println("ok!");
	//TransformationArtifact artifact = transformationArtifact(undefinedProject(), []);
	//SyntaxTree syntaxTree = parseCompleteProject(projectFile);
	//syntaxTree = checkSyntaxTree(syntaxTree);
	
	//if (size(syntaxTree.errors) == 0){
	//	artifact = transformSyntaxTree(syntaxTree);
	//	artifact = checkTransformationArtifact(artifact);
	//}
	//else{
	//	artifact.errors = syntaxTree.errors;
	//}
	//return artifact;
}
	     

