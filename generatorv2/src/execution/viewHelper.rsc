module execution::viewHelper
import visual::IDE::IDE;

/* Prelude */
import IO;
import String;
import List;

/* salix */
import salix::HTML;
import salix::App;
import salix::lib::Dagre;
import salix::lib::CodeMirror;
import salix::lib::Mode;
import salix::Core;
import salix::SVG;

/* Parsing */
import errors::Parsing;
import parsing::Parser;
import parsing::DataStructures;
import parsing::Syntax;
import errors::Parsing;

/* Execution */
import execution::Execution;
import execution::DataStructures;


void viewProject(Model model)
{
  div(class("container"), () {
    div(class("row"), () {
		div(class("col-md-6"), () {
			h3 ("Selected file: <model.projectViewInfo.selectedFile>");
			button(class("saveButton btn btn-secondary"), onClick(saveChanges()), "Save changes");

			codeMirror("cm", onChange(cmChange), style(("height": "50%")),
			  lineNumbers(true), \value(model.projectViewInfo.src), lineWrapping(true), class("cm-s-3024-night"));
		});
		div(class("col-md-6"), () {
			if (model.projectViewInfo.transformationArtifact.project == undefinedProject())
				h3("No project to parse..");
			//else if (size(model.projectViewInfo.transformationArtifact.project.errors) > 0)
			//	for (str error <- model.projectViewInfo.transformationArtifact.project.errors)
			//		h4(error);
			else{
				if(model.projectViewInfo.transformationArtifact.errors != [])
					viewParsingErrors(model.projectViewInfo.transformationArtifact.errors);	
				else{
					viewAlphabet(model.projectViewInfo.transformationArtifact.project.alphabet);
					viewGrammar(model);
					viewPipeline(model);
				}
			}
		});
    });
  });
}