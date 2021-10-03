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
import errors::Parsing;

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
		str src,
		Mode mode, 
		list[str] projectFiles,
		str selectedFile,
		TransformationArtifact transformationArtifact
	];
	
alias ExecutionViewInfo
	= tuple[
		ExecutionArtifact executionArtifact,
		int currentStep
	];
	

public void viewHeader(Model model) {
	header(() {
		nav(class("navbar navbar-inverse navbar-static-top"), () {
			a(class("navbar-brand"), onClick(goHome()), href("#"), () {
				text("AMG");
			});
			ul(class("nav navbar-nav"), () {
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
			  	li(() {
					a(href("#"), onClick(executeProject()), "Execute");
				});
			});
		});
	});
}


void drawSymbolMap(SymbolMap symbolMap, int svgWidth, int svgHeight){
	int tileHeight = svgHeight / size(symbolMap);
	int tileWidth = svgWidth / size(symbolMap[0]);
	
	if(tileHeight < tileWidth) tileWidth = tileHeight;
	svgWidth = tileWidth * size(symbolMap[0]);
	
	//println("svgw <svgWidth> svgHeight <svgHeight> tile width <tileWidth>");
	
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

int calculateSvgHeight(int width, int tileHor) {
	if (tileHor == 1)  return width /2;
	return width;
}

SymbolMap TileMapToSymbolMap(TileMap tileMap, AlphabetMap alphabet){
	return [[alphabet[tile] | str tile <- row] | list[str] row <- tileMap];
}

void drawRule(AlphabetMap alphabet, LudoscopeRule rule, str ruleName){
	int svgWidth = 100;
	int svgHeight = calculateSvgHeight(svgWidth, size(rule.lhs));
	
	//println("For rule <ruleName> svgHeight <svgWidth>");
	
	div(class("row"),() {
		h4("<ruleName>");
		div(class("ruleBox"),() {
	  		div(  () {
		  		SymbolMap symbolMap = TileMapToSymbolMap(rule.lhs, alphabet);
		  		drawSymbolMap(symbolMap, svgWidth, svgHeight);
	  		});
		  	div(class(" arrow"), () {
		  		text("➞");
		  	});
			div( () {
				SymbolMap symbolMap = TileMapToSymbolMap(rule.rhs, alphabet);
				drawSymbolMap(symbolMap, svgWidth, svgHeight);
			});
		});		
	});
}

void viewGrammar(Model model){
	println("view Grammar");
	AlphabetMap alphabet = 
		model.projectViewInfo.transformationArtifact.project.alphabet;

	list[LudoscopeModule] modules = model.projectViewInfo.transformationArtifact.project.modules;
	
	div(class("scrollBox container col-md-12"), () {
		for(LudoscopeModule \module <- modules){
			h3("Rules of module <\module.name>");
			hr();
			for (str ruleName <- \module.rules){
				LudoscopeRule rule = \module.rules[ruleName];
			  	drawRule(alphabet, rule, ruleName);
				hr();
		  	}
		}
	});
}

void viewPipeline(Model model){
	h3("Module Pipeline of \'<model.projectViewInfo.selectedFile>\'");
	rel[str, str] graph = {};
	for (int i <- [1 .. size(model.projectViewInfo.transformationArtifact.project.modules)])
	{
		LudoscopeModule \module = model.projectViewInfo.transformationArtifact.project.modules[i-1];
		LudoscopeModule higherModule = model.projectViewInfo.transformationArtifact.project.modules[i];
		
		graph += {<"<\module.name>", "<higherModule.name>">};
	}
	 println("graph <graph> <size(model.projectViewInfo.transformationArtifact.project.modules)>");
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

void viewParsingErrors (list[ParsingError] errors){
//<div class="danger">
//  <p><strong>Danger!</strong> Some text...</p>
//</div>
	div(class("danger"), (){
		p((){
			text("Parsing errors");			
			
		});
		ul((){
			for(ParsingError error <- errors){
				li(errorToString(error));
			}
		});
	});
}


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

void viewHistory(Model model)
{
	ExecutionHistory history = model.executionViewInfo.executionArtifact.history;
	div(class("col-md-3 executionHistory"), () {
		table(class("table table-hover table-condensed"), () {
			thead(() {
				th(scope("col"), class("text-center"), () {
					text("#");
				});
				th(scope("col"), class("text-center"), () {
					text("Module");
				});
				// TODO: add instruction back.
				//th(scope("col"), class("text-center"), () {
				//	text("Instruction");
				//});
				th(scope("col"), class("text-center"), () {
					text("Rule");
				});
			});
			tbody(() {
				for(int i <- [0 .. size(history)])
				{
					HistoryEntry step = history[i];
					str rowClass = "";
					if (i == model.executionViewInfo.currentStep)
					{
						rowClass = "active";
					}
					tr(class(rowClass), onClick(setStep(i)), () {
						th(scope("row"), () {
							text("<i>");
						});
						th(scope("row"), () {
							text(step.moduleName);
						});
						// TODO: add instruction back.
						//th(scope("row"), () {
						//	text(step.instruction);
						//});
						th(scope("row"), () {
							text(step.ruleName);
						});
					});
				}
			});
		});
	});
}

void viewExecution(model){
	if (model.executionViewInfo.executionArtifact == emptyExecutionArtifact()){
		h3("The project stil contains parsing errors..");
	}else if(model.executionViewInfo.executionArtifact.errors != []){
	  	h3("The project contains execution errors..");
	}else{
		println("view ex");
		ExecutionHistory history = model.executionViewInfo.executionArtifact.history;
		
		div(class("container"), () {
			div(class("row"), () {
				/* History */
				viewHistory(model);
				/* Visual */
				div(class("col-md-6"), () {
					HistoryEntry step = history[model.executionViewInfo.currentStep];
				
					LudoscopeProject project = model.projectViewInfo.transformationArtifact.project;
	
					AlphabetMap alphabet = project.alphabet;
					
					TileMap tileMap = step.before;	
					int svgWidth = 200;
					int svgHeight 
						= calculateSvgHeight(svgWidth, size(tileMap));
					
					div(class("row svgWrapper text-center"), style(<"height", "<svgHeight>px;">), () {				
					
				  		div(class("col-md-4 svgWrapper text-center"),  () {
					  		SymbolMap symbolMap = TileMapToSymbolMap(step.before, alphabet);
					  		drawSymbolMap(symbolMap, svgWidth, svgHeight);
				  		});
					  	div(class("col-md-2 arrow"), () {
					  		text("➞");
					  	});
						div(class("col-md-4 svgWrapper text-center"), style(<"height", "<svgHeight>px;">), () {
							SymbolMap symbolMap = TileMapToSymbolMap(step.after, alphabet);
							drawSymbolMap(symbolMap, svgWidth, svgHeight);
						});
					});
					hr();
					
				});
				
			});
		});
	}
}
public void view(Model model) {
  div(() {
  	viewHeader(model);
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
	
private loc projectsFolder = |project://generatorv2/src/tests|;

Model init() {
	Mode mode = grammar2mode("Project pipeline", #Pipeline);
	list[str] projects = listEntries(projectsFolder);
    str selectedFile = projects[0]; 
	str src = readFile(projectsFolder + selectedFile);
	ProjectViewInfo projectViewInfo = <
			src, 
			mode, 
			projects, 
			selectedFile, 
			emptyArtifact()
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
  = goHome() 
  | cmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | selectedProject(str folder)
  | selectedFile(str file)
  | saveChanges()
  | changeView(View newView)
  | executeProject()
  | setStep(int newStep)
   //| setItterations(int itterations)
  //| startNewAnalysis()
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
  if (to < size(src)) newSrc = src[..from] + text + src[to..];
  else newSrc = src[..from] + text;
  return newSrc;
}

Model update(Msg msg, Model model) {
 println("update Called msg <msg>");
  switch (msg) {
  	case goHome(): {
  		model.view = projectView();
  	}
  	case changeView(View newView): {
  		model.view = newView;
  	}
  	case executeProject():{
  	println("trying to execute");
  		model.executionViewInfo.executionArtifact = executeProjectAndCheck(model.projectViewInfo.transformationArtifact);
  		model.view = executionView();
  		println("Executed project");
  	}
    case cmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed):{
      	model.projectViewInfo.src = updateSrc(model.projectViewInfo.src, fromLine, fromCol, toLine, toCol, text, removed);
    	println("updating source \n <model.projectViewInfo.src>");
	}
    case selectedFile(str file):{
    	model = selectFile(model, file);
    	model.view = projectView();
    }
    case saveChanges():{
    	loc file = projectsFolder + model.projectViewInfo.selectedFile;
    	writeFile(file, model.projectViewInfo.src);
    	model = tryAndParse(model);
    	
    }
    case setStep(int newStep):{
    	model.executionViewInfo.currentStep = newStep;
    }
  }
  return model;
}

Model tryAndParse(Model model){
	println("tryAndParse Called");
  	str file =  model.projectViewInfo.selectedFile;
	loc projectFile = projectsFolder + file;
	model.projectViewInfo.transformationArtifact = parseProjectFromLoc(projectFile);

	return model;
}

void viewAlphabet(AlphabetMap alphabet){
div(class("scrollBox container col-md-12"), () {
		h3("Alphabet");
		hr();
	div(class("scrollBox container col-md-12 alphabetBox"), () {
		for (str entryName <- alphabet){
			div(class(" alphabetItem"), () {
				svg(height("30px"), width("30px"), () {
					rect(
						style("x:0;y:0;"),
					 	width("30"), 
					 	height("30"),
					 	fill(alphabet[entryName].color), 
					 	stroke("black"),
					 	strokeWidth("1"));
				});
				h4(alphabet[entryName].name);
			});
		}
	});
});
}


Model selectFile(Model model, str file){	
	model.projectViewInfo.selectedFile = file;
	model.projectViewInfo.src = readFile(projectsFolder + file);
	
	model = tryAndParse(model);
	
	return model;
}
