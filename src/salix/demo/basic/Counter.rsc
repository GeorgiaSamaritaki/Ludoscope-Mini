@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Counter

import salix::App;
import salix::HTML;

alias Model = tuple[int count];

Model init() = <0>;

SalixApp[Model] counterApp(str id = "root") = makeApp(id, init, view, update);

App[Model] counterWebApp()
  = webApp(
      counterApp(),
      |project://generatorv2/src/salix/demo/basic/index.html|, 
      |project://generatorv2/src|
    );
data Msg
  = inc()
  | dec()
  ;

Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): m.count += 1;
    case dec(): m.count -= 1;
  }
  return m;
}

void view(Model m) {
  div(() {
    
    h2("My first counter app in Rascal");
    
    button(onClick(inc()), "+");
    
    div("<m.count>");
    
    button(onClick(dec()), "-");

  });
}

