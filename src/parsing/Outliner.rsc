module parsing::Outliner

import List;
import parsing::AST; 

import util::LanguageServer; 
import util::Reflective;
import IO;
import ParseTree;

PathConfig LDpcfg = pathConfig(srcs=[|project://ludoscope-mini/src|]);

set[LanguageService] LDContributions() = {
    parser(LDParser), 
    outliner(ldOutliner),
    summarizer(ldSummarizer, providesImplementations = false)
  };


Summary ldSummarizer(loc l, start[Program] input) {
    rel[loc, str] docs;
    rel[loc, loc] defs;
    rel[loc, loc] refs;
    rel[loc, loc] impls; 

     println("summarizer");

    return summary(l,
        messages = {<src, error("<id> is not defined", src)> | <src, id> <- uses, id notin defs<0>},
        documentation = docs,
        definitions = defs,
        references = refs,
        implementations = impls
    );
}

list[DocumentSymbol] ldOutliner(start[Pipeline] pipeline) {

     println("oulining");

    list[DocumentSymbol] alphabetSymbols = [];

    for(symbolInfo <- pipeline.alphabet.symbols){
        
        alphabetSymbols += symbol(
            symbolInfo.name.val, 
            DocumentSymbolKind::String(), 
            symbolInfo.src
            ); 
    
    } 
    println("oulining");

    list[DocumentSymbol] moduleSymbols = [];
    for (m <- pipeline.modules){
        moduleSymbols += outlineModule(m); 
    }

    /* 
    list[DocumentSymbol] constraintSymbols = [
        outlineConstraint(constraint) 
        for constraint <- pipeline.constraints
    ];

    list[DocumentSymbol] handlerSymbols = [
        outlineHandler(handler) 
        for handler <- pipeline.handlers
    ];
    */
    return [
        symbol("Pipeline", DocumentSymbolKind::Namespace(), |unknown:///|, children=
            alphabetSymbol + moduleSymbols
        )
    ];
}

DocumentSymbol outlineMod(Module modul) {
    // outlineRecipe(mod.recipe),
    // *outlineConstraint(constraint) | constraint <- mod.constraints

    return symbol(
        modul.name.val,
        DocumentSymbolKind::Namespace(),
        modul.src,
        children=[
            outlineRules(modul.rules)
        ]
    );
}


private DocumentSymbol outlineRules(Rules rules) {
    return symbol(
        "Rules",
        DocumentSymbolKind::Namespace,
        rules.src,
        children=[] + 
            [*symbol(rule.name.val, DocumentSymbolKind::Function(), rule.src) | rule <- rules.rules]
    );
}
