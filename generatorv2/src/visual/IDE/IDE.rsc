module visual::IDE::IDE

//import visual::IDE::View;

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

alias SymbolMap = list[list[AlphabetEntry]];

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
	

public void viewHeader(Model model) {
	header(() {
		nav(class("navbar navbar-inverse navbar-static-top"), () {
			a(class("navbar-brand"), href("#"), () {
				text("Ludoscope Lite");
			});
			ul(class("nav navbar-nav"), () {
				li(class("dropdown"), () {
					a(class("dropbtn"), href("#"), () {
						text("Project");
						span(class("caret"), () {});
					});
					ul(class("dropdown-content"), () {
						for (str project <- model.projectViewInfo.projectFiles)
						{
							if (project == model.projectViewInfo.selectedFile)
							{
							  li(class("active"), () {
									a(href("#"), onClick(selectedProject(project)), project);
								});
							}
							else
							{
							  li(() {
									a(href("#"), onClick(selectedProject(project)), project);
								});
							}
						}
					});
				});
				li(class("dropdown"), () {
					a(class("dropbtn"), href("#"), () {
						text("File");
						span(class("caret"), () {});
					});
					ul(class("dropdown-content"), () {
						for (str file <- model.projectViewInfo.projectFiles)
						{
							if (file == model.projectViewInfo.selectedFile)
							{
							  li(class("active"), () {
									a(href("#"), onClick(selectedFile(file)), file);
								});
							}
							else
							{
							  li(() {
									a(href("#"), onClick(selectedFile(file)), file);
								});
							}
						}
					});
				});
				li(class("dropdown"), () {
					a(class("dropbtn"), href("#"), () {
						text("Execute");
						span(class("caret"), () {});
					});
					ul(class("dropdown-content"), () {
					  li(() {
							a(href("#"), onClick(changeView(executionView())), "Execute project");
						});
						li(() {
							a(href("#"), onClick(generateSoundLevel()), "Generate sound level");
						});
						li(() {
							a(href("#"), onClick(changeView(bugReportView())), "SaNR analysis");
						});
					});
				});
			});
		});
	});
}
void drawSymbolMap(SymbolMap symbolMap, int svgWidth)
{
	int tileWidth = svgWidth / size(symbolMap[0]);
	int tileHeight = svgWidth / size(symbolMap);
	
	if(tileHeight < tileWidth) tileWidth = tileHeight;
	int svgHeight = tileWidth * size(symbolMap);
	
	println("svgw <svgWidth> svgHeight <svgHeight> tile width <tileWidth>");
	
	svg(height("<svgHeight>px"), width("<svgWidth>px"), () {		
		for (int row <- [0 .. size(symbolMap)]){
			for (int column <- [0 .. size(symbolMap[0])]){
				AlphabetEntry symbol = symbolMap[row][column];
				rect(
				 	style("x:<column * tileWidth>; 
				 		   y:<row * tileWidth>; "),
				 	width("<tileWidth - 1>"), 
				 	height("<tileWidth - 1>"),
				 	fill(symbol.color), 
				 	stroke("black"), 
				 	strokeWidth("0.5")
				 	);
				 	//onMouseOver(changeFocus(<column, row>)));
			}
		}
	});
}

int calculateSvgHeight(int width, int tilesHor) {
	int tileWidth = width / tilesHor;
	if (tileWidth == width)
		tileWidth = width /2;
	return tileWidth * tilesHor;
}

SymbolMap TileMapToSymbolMap(TileMap tileMap, AlphabetMap alphabet){
	return [[alphabet[tile] | str tile <- row] | list[str] row <- tileMap];
}

void drawRule(AlphabetMap alphabet, LudoscopeRule rule){
	int svgWidth = 100;
	int svgHeight 
		= calculateSvgHeight(svgWidth, size(rule.lhs));
	
	println("For rule <size(rule.lhs[0])>/<size(rule.rhs)> svgHeight <svgHeight>");
	
	div(class("row"), style(<"height", "<svgHeight>px;">),() {
  		div(class("col-md-4 svgWrapper text-center"),  () {
	  		SymbolMap symbolMap = TileMapToSymbolMap(rule.lhs, alphabet);
	  		drawSymbolMap(symbolMap, svgWidth);
  		});
	  	div(class("col-md-2 arrow"), () {
	  		text("➞");
	  	});
		div(class("col-md-4 svgWrapper text-center"), style(<"height", "<svgHeight>px;">), () {
			SymbolMap symbolMap = TileMapToSymbolMap(rule.rhs, alphabet);
			drawSymbolMap(symbolMap, svgWidth);
		});
		//div(class("col-md-1"), () {
		//	viewOptionsRule(rule.reflections, madScores[0].score);
		//});
	});
}

void viewGrammar(Model model){
	println("view Grammar");
	AlphabetMap alphabet = 
		model.projectViewInfo.parsedProject.alphabet;

	list[LudoscopeModule] modules = model.projectViewInfo.parsedProject.modules;
	
	div(class("scrollBox container col-md-12"), () {
		for(LudoscopeModule \module <- modules){
			h3("Rules of module <\module.name>");
			hr();
			for (str ruleName <- \module.rules){
				LudoscopeRule rule = \module.rules[ruleName];
			 	div(class("row"), () {
			  		h4(ruleName);
			  		//h4(rule);
			  	});
			  	
			  	drawRule(alphabet, rule);
				hr();
		  	}
		}
	});
}

void viewPipeline(Model model){
	h3("Module Pipeline of \'<model.projectViewInfo.selectedFile>\'");
	rel[str, str] graph = {};
	for (int i <- [1 .. size(model.projectViewInfo.parsedProject.modules)])
	{
		LudoscopeModule \module = model.projectViewInfo.parsedProject.modules[i-1];
		LudoscopeModule higherModule = model.projectViewInfo.parsedProject.modules[i];
		
		graph += {<"<\module.name>", "<higherModule.name>">};
	}
	 println("graph <graph> <size(model.projectViewInfo.parsedProject.modules)>");
	dagre("pipeline", rankdir("LR"), width(500), height(500), marginx(100), marginy(100), (N n, E e) {
	    for (str x <- graph<0> + graph<1>) {
	      n(x, shape("circle"), () {
	      	div(() {
	      		a(class("moduleLink"), href("#"), onClick(selectedFile(x + ".grm")), x);
	        });
	      });
	    }
	    for (<str x, str y> <- graph) {
	      e(x, y, lineInterpolate("cardinal"));
	    }
	});
	
}

void viewProject(Model model)
{
  div(class("container"), () {
    div(class("row"), () {
		div(class("col-md-6"), () {
			button(class("saveButton btn btn-secondary"), onClick(saveChanges()), "Save changes");

			codeMirrorWithMode("cm", model.projectViewInfo.mode, onChange(cmChange), style(("height": "50%")),
			  lineNumbers(true), \value(model.projectViewInfo.initialSrc), lineWrapping(true), class("cm-s-3024-night"));
			
		});
		div(class("col-md-6"), () {
			if (model.projectViewInfo.parsedProject == undefinedProject())
				h3("No project to parse..");
			//else if (size(model.projectViewInfo.parsedProject.errors) > 0)
			//	for (str error <- model.projectViewInfo.parsedProject.errors)
			//		h4(error);
			else{
				viewGrammar(model);
				viewPipeline(model);
			}
		});
    });
  });
}


public void view(Model model) {
  div(() {
  	viewHeader(model);
    viewProject(model);
    switch (model.view)
    {
    	case projectView(): viewProject(model);
    	case executionView(): viewExecution(model);
    	//case bugReportView(): viewBugReport(model);
    	default: println("view went to default");
    }


	//viewFooter(model);
  });
}


//alias BugReportViewInfo
//	= tuple[
//		//Report bugReport,
//		int itterations
//		//BugType selectedBugType
//	];
	
private loc projectsFolder = |project://generatorv2/src/tests/test1|;

Model init() {
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
  println("updateSrc Called");
  src = replaceAll(src, "\r\n", "\n");
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
 println("update Called msg <msg>");
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
	println("tryAndParse Called");
  	str file =  model.projectViewInfo.selectedFile;
	loc projectFile = projectsFolder + file;
	model.projectViewInfo.parsedProject = parseProjectFromLoc(projectFile);

	return model;
}

//Model generateSoundLevel(Model model)
//{
//	ExecutionArtifact artifact = model.executionViewInfo.executionArtifact;
//		
//	// TODO: 100 executions can take a long time. Measure time.
//	for (int i <- [0 .. 100]){
//		PropertyStates finalPropertyStates = last(artifact.propertyReport.history).propertyStates;
//		
//		if (false in finalPropertyStates)
//		{
//			model.executionViewInfo.executionArtifact 
//				= executeProject(model.projectViewInfo.parsedProject.project);
//		}else{
//			return model;
//		}
//	}
//	println("Couldn\'t generate sound level");
//	
//	return model;
//}