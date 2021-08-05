module utility::TileMap

import IO;
import List;
import analysis::graphs::Graph;

import parsing::DataStructures;

public list[list[str]] createTileMap(int width, int height, str symbol){
	return [[symbol | int i <- [0 .. width]] | int j <- [0 .. height]];
}

public void printTileMap(list[list[str]] \map){
	println("TileMap");
	for(list[str] row <- \map){
		println(row);
	}
}

public tuple[int,int] patternSize(list[list[str]] \map){
	return <size(\map),size(\map[0])>;
}

public list[tuple[int,int]] getAllCoordinates(
	Coordinates c, 
	tuple[int height,int width] size){ 
	println("pattern starts at <c>");
	list[tuple[int,int]] cset = [];
	for(int i <-[0..size.height])
		for(int j<-[0..size.width])
			cset += [<c.x + i, c.y + j>];
	return cset; 
	//return [[<c.x + i, c.y + j> | int i <- [0 .. height]] | int j <- [0 .. width]];;
}

public lrel[int,int] findInMap(list[list[str]] \map, str toFind){
	return [<i,j> | int i <- [0..size(\map)], int j <- [0..size(\map[0])], \map[i][j] == toFind];
}

public str getTile(list[list[str]] \map, Coordinates c){
	if(c.x >= size(\map) || c.y >= size(\map[0])) return "";
	return \map[c.x][c.y];
}

public TileMap replacePattern(list[list[str]] \map, TileMap pattern, Coordinates coordinates){
	int patternHeight = size(pattern);
	int patternWidth = size(pattern[0]);
	 
	for (int i <- [0 .. patternWidth])
		for (int j <- [0 .. patternHeight]){
			\map[j + coordinates.x][i + coordinates.y] = 
				pattern[j][i];
		}
	return \map;		
}

public TileMap changeTile(str s, Coordinates c, list[list[str]] \map){
 	\map[c.x][c.y] = s;
 	return \map;
}

public Graph[Coordinates] getGraph(list[list[str]] \map){
	Graph[Coordinates] g = {};
	
	for(int i <- [0..size(\map)]){
		for(int j <- [0..size(\map[0])]){
			if(isReachable(<i,j>,\map)){
				Coordinates current = <i,j>;
				Coordinates r = getRight(current), l = getLeft(current),
					u = getUp(current), d = getDown(current);
			
				if(isReachable(r,\map)) g += {<current,r>};
				if(isReachable(l,\map)) g += {<current,l>};
				if(isReachable(u,\map)) g += {<current,u>};
				if(isReachable(d,\map)) g += {<current,d>};
			
			}
		}
	}
	
	return g;	
}

public list[Coordinates] shortestPathInGraph(
	Graph[Coordinates] g, 
	str a, str b,
	list[list[str]] \map
){
	list[Coordinates] current = findInMap(\map,a), 
				target = findInMap(\map,b);
				
	return shortestPathPair(g,current[0],target[0]);
}

//////////////////////////////////////////////
//Utility
//////////////////////////////////////////////

private bool isReachable(Coordinates c, list[list[str]] \map){
	if(c.x >= size(\map) || c.y >= size(\map[0])) return false;
	str target = \map[c.x][c.y];
	return target == "f" || target == "e" || target == "x"; //not ideal
}

private Coordinates getRight(Coordinates c){ return <c.x,c.y+1>; }
private Coordinates getLeft (Coordinates c){ return <c.x,c.y-1>; }
private Coordinates getDown (Coordinates c){ return <c.x+1,c.y>; }
private Coordinates getUp   (Coordinates c){ return <c.x-1,c.y>; }












