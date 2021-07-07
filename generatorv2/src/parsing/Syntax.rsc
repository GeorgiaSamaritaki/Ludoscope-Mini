module parsing::Syntax

import ParseTree;

lexical LAYOUT 
	= [\t\r\ ]
	| ^ Comment Newlines
	> Comment //nested in code
	;
layout LAYOUTLIST = LAYOUT* !>> [\t\r\ )];


lexical Comment = @category="Comment" "(" (![()]|Comment)+ ")";
lexical Newline = [\n];
lexical Newlines = Newline+ !>> [\n];
lexical SectionDelimiter = [=]+ Newlines;

lexical BOOLEAN
	= @category="Boolean" "true" | "false";

lexical NAME
  = @category="Name" ([a-zA-Z_$.] [a-zA-Z0-9_$.]* !>> [a-zA-Z0-9_$.]) \ Keywords;

lexical CHAR
  = @category="Character" ([a-zA-Z0-9_$.]);


lexical COLORCODE
	= @category="ColorCode" "#" [0-9A-Z]*;
 
lexical INTEGER
  = ("-"?[0-9]+);
  
lexical FLOAT
  = INTEGER ([.][0-9]+?)? "f";
    
lexical STRING
  = ![\"]*;

keyword SectionKeyword =  'NAME' | 'ALPHABET' | 'RULES' | 'RECIPE' | 'CONSTRAINTS';

//'RULES' | 'OBJECTS' | 'LEGEND' | 'COLLISIONLAYERS' | 'SOUNDS' | 'WINCONDITIONS' | 'LEVELS'
keyword PreludeKeyword 
	= 'title' | 'author' | 'homepage' | 'color_palette' | 'again_interval' | 'background_color' 
	| 'debug' | 'flickscreen' | 'key_repeat_interval' | 'noaction' | 'norepeat_action' | 'noundo'
	| 'norestart' | 'realtime_interval' | 'require_player_movement' | 'run_rules_on_level_start' 
	| 'scanline' | 'text_color' | 'throttle_movement' | 'verbose_logging' | 'youtube ' | 'zoomscreen';
//keyword LegendOperation = 'or' | 'and';
//
//keyword Directional = 'up' | 'down' | 'right' | 'left' ;
//keyword Moving = 'moving';
//keyword Orientiation = 'vertical' | 'horizontal';
//keyword No = 'no';

keyword Keywords = SectionKeyword | PreludeKeyword; 
// | LegendOperation;

start syntax LDGame
 	= game: Prelude Section+
 	| empty: Newlines
 	;

syntax Prelude
	= prelude: PreludeData+
	| empty: Newlines
	;

syntax PreludeData
	= prelude_data: PreludeKeyword STRING* Newlines
	;

syntax Section
 	= name: Name
 	| alphabet: Alphabet
 	| rules: Rules
 	| recipe: Recipe
 	| constraints: Constraints
 	| empty: SectionDelimiter? SectionKeyword Newlines SectionDelimiter?
 	; 	
 	
syntax Name
	= name: Newlines '#NAME' Newlines NAME name
	;

syntax Alphabet
	= name: Newlines '#NAME' Newlines Alphabet_entry+
	;
	
syntax Alphabet_entry
 = alphabet_entry: NAME name CHAR symbol COLORCODE color
 ;

syntax Rules
	= rules: Newlines '#RULES' Newlines Rule+
	;
	
syntax Rule
	= rule: 
			NAME name ":" 
			Pattern leftHand "-\>" 
			Pattern rightHands;

lexical Pattern 
	= content: STRING
	| empty: 
	;
	
syntax Recipe
    = recipe: Newlines '#RECIPE' Newlines Call+
	;
	
syntax Call
   	= rulename: NAME ruleName |
   	  createGraph: CreateGraph;
   	  
syntax CreateGraph
    = createPath: "CreatePath" "(" CHAR CHAR")";

syntax Constraints
    = constrains: Newlines '#Constraints' Newlines Constraint+;
    
syntax Constraint
	= ;//Boolean expressions?
