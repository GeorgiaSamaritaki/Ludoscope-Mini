module visual::IDE::IDE

import visual::IDE::View;

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

/* Execution */
import execution::Execution;
import execution::DataStructures;

alias Model = 
	tuple[
		View view,
		ProjectViewInfo projectViewInfo,
		ExecutionViewInfo executionViewInfo
		//,BugReportViewInfo bugReportViewInfo
	];

SalixApp[Model] ldApp(str id = "root") = makeApp(id, init, view, update);

App[Model] ldWebApp()
  = webApp(
      ldApp(),
      |project://generatorv2/src/visual/IDE/index.html|, 
      |project://generatorv2/src|
    );

alias ProjectViewInfo
	= tuple[
		str initialSrc,
		str updatedSrc,
		Mode mode, 
		list[str] projectFiles,
		str selectedFile,
		LudoscopeProject parsedProject
	];
	
alias ExecutionViewInfo
	= tuple[
		ExecutionArtifact executionArtifact,
		int currentStep
	];
	
//alias BugReportViewInfo
//	= tuple[
//		//Report bugReport,
//		int itterations
//		//BugType selectedBugType
//	];
	
private loc projectsFolder = |project://generatorv2/src/tests/test1|;

Model init() {
	println("Init called");
	Mode mode = grammar2mode("Project pipeline", #Pipeline);
	list[str] projects = listEntries(projectsFolder);
    str selectedFile = projects[0]; 
	str src = readFile(projectsFolder + selectedFile);
	
	ProjectViewInfo projectViewInfo = <
			src, 
			src, 
			mode, 
			projects, 
			selectedFile, 
			undefinedProject()
		>;
		
	ExecutionViewInfo executionViewInfo = <
			emptyExecutionArtifact(),
			0
		>;
		
	Model newModel = <
			projectView(),
			projectViewInfo,
			executionViewInfo
			//,			bugReportViewInfo
		>;

	newModel = tryAndParse(newModel);
	println("Parsed!");
	return newModel;
}

data View
	= projectView()
	| executionView()
	| bugReportView();

data Msg
  = cmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | selectedProject(str folder)
  | selectedFile(str file)
  | saveChanges()
  | changeView(View newView)
  | setStep(int newStep)
  | setItterations(int itterations)
  | startNewAnalysis()
  //| setBugType(BugType bugType)
  | inspectExecution(ExecutionArtifact executionArtifact, int currentStep)
  | generateSoundLevel();

private list[str] mySplit(str sep, str s) {
  if (/^<before:.*?><sep>/m := s) {
    return [before] + mySplit(sep, s[size(before) + size(sep)..]);
  }
  return [s];
}

private str updateSrc(str src, int fromLine, int fromCol, int toLine, int toCol, str text, str removed) {
  // NOTE: Added this for microsoft line breaks.
  str src = replaceAll(src, "\r\n", "\n");
  list[str] lines = mySplit("\n", src);

  int from = (0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
  int to = from + size(removed);
  
  str newSrc;
  if (to < size(src))
  {
    newSrc = src[..from] + text + src[to..];
  }
  else
  {
  	newSrc = src[..from] + text;
  	
  }  
  return newSrc;
}

Model update(Msg msg, Model model) {
  switch (msg) {
  	case changeView(View newView):
  	{
  		model.view = newView;
  	}
    case cmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed):
    {
      model.projectViewInfo.updatedSrc = updateSrc(model.projectViewInfo.updatedSrc, fromLine, fromCol, toLine, toCol, text, removed);
	  }
    case selectedProject(str folder):
    {
  //  	model.projectViewInfo.selectedProject = folder;
  //  	model.projectViewInfo.projectFiles = listEntries(projectsFolder + folder);
  //  	model = selectFile(model, model.projectViewInfo.projectFiles[0]);
  //  	
		//model = tryAndParse(model);
		//model.bugReportViewInfo.bugReport = emptyReport();
		//model.executionViewInfo.currentStep = 0;
			;
    }
    case selectedFile(str file):
    {
    	model = selectFile(model, file);
    	model.view = projectView();
    }
    case saveChanges():
    {
    	//loc file = projectsFolder 
    	//	+ model.projectViewInfo.selectedProject 
    	//	+ model.projectViewInfo.selectedFile;
    	//writeFile(file, model.projectViewInfo.updatedSrc);
    	//model = tryAndParse(model);
    	;
    }
    case setStep(int newStep):
    {
    	model.executionViewInfo.currentStep = newStep;
    }
    case setItterations(int itterations):
    {
    	model.bugReportViewInfo.itterations = itterations;
    	;
    }
    case startNewAnalysis():
    {
    	model.bugReportViewInfo.bugReport 
    		= analyseProject(model.projectViewInfo.parsedProject.project, 
    			model.bugReportViewInfo.itterations);
    }
    //case setBugType(BugType bugType):
    //{
    //	model.bugReportViewInfo.selectedBugType = bugType;
    //}
    case inspectExecution(ExecutionArtifact executionArtifact, int currentStep):
    {
    	model.view = executionView();
    	model.executionViewInfo.executionArtifact = executionArtifact;
    	model.executionViewInfo.currentStep = currentStep;
    }
    case generateSoundLevel():
    {
    	model = generateSoundLevel(model);
    	model.view = executionView();
    }
  }
  return model;
}

Model tryAndParse(Model model){
	println("try and parse called");
  	str file =  model.projectViewInfo.selectedFile;
	loc projectFile = projectsFolder + model.projectViewInfo.selectedProject + file;
	
	model.projectViewInfo.parsedProject = parseProject(projectFile);

	return model;
}

Model generateSoundLevel(Model model)
{
	ExecutionArtifact artifact = model.executionViewInfo.executionArtifact;
		
	// TODO: 100 executions can take a long time. Measure time.
	for (int i <- [0 .. 100])
	{
		PropertyStates finalPropertyStates = last(artifact.propertyReport.history).propertyStates;
		
		if (false in finalPropertyStates)
		{
			model.executionViewInfo.executionArtifact 
				= executeProject(model.projectViewInfo.parsedProject.project);
		}
		else
		{
			return model;
		}
	}
	println("Couldn\'t generate sound level");
	
	return model;
}