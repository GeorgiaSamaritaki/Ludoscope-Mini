module visual::IDE::ViewHelper
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

/* Execution */
import execution::Execution;
import execution::DataStructures;

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
