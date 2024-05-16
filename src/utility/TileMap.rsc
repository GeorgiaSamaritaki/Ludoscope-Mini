//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file contains all the functions all around TileMapToSymbolMap
//			These functions are used throughout execution		
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    10-10-2021
//
//////////////////////////////////////////////////////////////////////////////
module utility::TileMap

import IO;
import List;
import Set;

import analysis::graphs::Graph;
import errors::Execution;

alias TileMap = list[list[Tile]];
alias Tile = str;
alias Coordinates = tuple[int x, int y];

str undefined = "?";

public list[list[str]] createTileMap(int width, int height, str symbol){
	return [[symbol | int _ <- [0 .. width]] | int _ <- [0 .. height]];
}

public void printTileMap(list[list[str]] \map){
	println("TileMap");
	for(list[str] row <- \map){
		println(row);
	}
} 

//Returns <height, width>
public tuple[int,int] patternSize(TileMap \map){
	return <size(\map),size(\map[0])>;
}

//Produce all the coordinates the rectangle with size.width for width
// and size.height  occupies with starting point c
public set[Coordinates] getAllCoordinates(
	Coordinates c, 
	tuple[int height,int width] size){ 

	return { <c.x + i, c.y + j> | 
			 int i <- [0 .. size.height] , int j <- [0 .. size.width]};
}

//Finds all ocurrences of "toFind" in the tilemap
public lrel[int,int] findInMap(list[list[str]] \map, str toFind){
	return [<i,j> | 
			int i <- [0..size(\map)], int j <- [0..size(\map[0])], 
			\map[i][j] == toFind];
}

// Function for matching pattern in a grid.
// @brief        the function for matching pattern 
//				 in a grid. Modified from Quinten's original version
// @contributor  Quinten Heijn - samuel.heijn@gmail.com - UvA
// @contributor  Georgia Samaritaki - UvA
// @date         20-04-2018 / 2-08-20
public set[Coordinates] findPatternInGrid(TileMap grid, TileMap pattern)
{
	set[Coordinates] matches = {};
	int patternWidth = size(pattern[0]);
	int patternHeight = size(pattern);
	int gridHeight = size(grid);
	list[str] patternFirstLine = pattern[0];
	
	for (/[*C, [*A, patternFirstLine, *B], *D] := grid)
	{
		int widthOffset = size(A);
		int heightOffset = size(C);
		bool match = true;
		if (heightOffset + patternHeight <= gridHeight){
			for (int row <- [heightOffset + 1 .. heightOffset + patternHeight]){
				if (pattern[row - heightOffset] != 
					grid[row][widthOffset .. widthOffset + patternWidth]){
					match = false;
					break;
				}
			}
			if (match){
				matches += {<heightOffset, widthOffset>};
			}
		}
	}
	return matches;
}

public set[Coordinates] tilemapDifference(TileMap map1, TileMap map2){
	return { <i,j> | int i <- [0 .. size(map1)] , int j <- [0 .. size(map1[0])],
			map1[i][j] != map2[i][j] };
}

public str getTile(list[list[str]] \map, Coordinates c){
	if(c.x >= size(\map) || c.y >= size(\map[0])) return "";
	return \map[c.x][c.y];
}

public TileMap replacePattern(
	list[list[str]] \map, 
	TileMap pattern, 
	Coordinates coordinates
){
	int patternHeight = size(pattern);
	int patternWidth = size(pattern[0]);
	 
	for (int i <- [0 .. patternHeight])
		for (int j <- [0 .. patternWidth]){
			\map[coordinates.x + i][coordinates.y + j] = 
				pattern[i][j];
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

public int countOccurences(str a, TileMap \map){
	int count = 0;
	for(list[str] row <- \map)
		count += size([s | str s <- row, s == a]);
	
	return count;
}

public bool inMap(str a, TileMap \map){
	for(list[str] row <- \map)
		for(str b <- row)
			if(a == b) return true;
	return false;
}

public list[&U] flatten(list[list [&U]] \map){
	list[&U] flat = []; 
	for (l <- \map) flat += l;
	return flat;
}

//Produces the coordinates that are included in the given coords
//eg IF the coords are the walls of a map this function 
// returns the inside as well
public set[Coordinates] fillInGaps(set[Coordinates] coords){
	Coordinates c = min(coords); //starting point
	int height = getMaxX(coords) - c.x + 1;
	int width = getMaxY(coords) - c.y + 1;
	
	set[Coordinates] extraCoordinates = {};
	
	for(int i <- [0 .. height])
		for(int j <- [0 .. width])
			extraCoordinates += {<c.x + i,c.y + j>};
	
	return coords + extraCoordinates;
}

public tuple[Coordinates, TileMap] extractSection(
	TileMap \map, 
	set[Coordinates] affectedArea){
	
	affectedArea = fillInGaps(affectedArea);
	
	return translateCoordinatesToTilemap(affectedArea, \map);
}

public tuple[Coordinates, TileMap] getAreaAround(
	TileMap \map,
	set[Coordinates] affectedArea,
	tuple[int height, int width] ruleSize){

	set[Coordinates] allCoords = 
		union( {getAllAround(c, ruleSize) | c<-affectedArea });
	
	return translateCoordinatesToTilemap(allCoords, \map);
}

public set[Coordinates] substractOffset(
	set[Coordinates] coords, 
	Coordinates offset){
	return { <c.x - offset.x, c.y - offset.y> | 
			c <- coords, c.x - offset.x >= 0 && c.y - offset.y >= 0};
}

public TileMap getAllButAreaAround(
	TileMap \map,
	set[Coordinates] affectedArea){

	set[Coordinates] allCoords = 
		union({getAllAround(c, <1,1>) | c<-affectedArea});
	
	return removeCoordinatesFromTileMap(\map, allCoords);
}

public TileMap removeCoordinatesFromTileMap(
	TileMap \map, 
	set[Coordinates] coords){
	for(c <- coords, c.x < size(\map) && c.y < size(\map[0]))
			\map[c.x][c.y] = undefined;
	return \map;
}

public set[Coordinates] getAllAround(
	Coordinates c, 
	tuple[int height, int width] ruleSize){
	
	return { <c.x + i , c.y + j> | 
			  i <- [-ruleSize.height..1 + ruleSize.height], 
			  j <- [-ruleSize.width ..1 + ruleSize.width], 
			  c.x + i >= 0 && c.y + j >= 0} - c;
}


public tuple[Coordinates, TileMap] translateCoordinatesToTilemap(
	set[Coordinates] coords, 
	TileMap \map){
	
	if(isEmpty(coords)) return <<-1,-1>,\map>;
	
	Coordinates startingPoint = min(coords);
	int height = getMaxX(coords) - startingPoint.x + 1;
	int width = getMaxY(coords) - startingPoint.y + 1;
	
	TileMap newMap = createTileMap(width, height, undefined);
	
	for(c <- coords){
	  if(c.x >= size(\map) || c.y >= size(\map[0])
	  	|| c.x < 0 || c.y < 0){ 
		printError("Got coords out of the map");
	  }else 
		  newMap[c.x - startingPoint.x][c.y - startingPoint.y] = \map[c.x][c.y];
	}
	return <startingPoint, newMap>;
}

//Determines all the coordinates that are included in a shape
// eg if we have the outerwalls of a room this function outputs all the coordinates
//    that consitute that room

//not exactly correct for odd shapes
public set[Coordinates] fillInCoordinates(set[Coordinates] coords){
	Coordinates startingPoint = min(coords);
	int height = max(coords).x - startingPoint.x + 1;
	int width = max(coords).y - startingPoint.y + 1;
	return { <startingPoint.x + i, startingPoint.y + j> | 
			 int i <- [0 .. height] , int j <- [0 .. width]};
}

//////////////////////////////////////////////
//Utility
//////////////////////////////////////////////

private bool isReachable(Coordinates c, list[list[str]] \map){
	if(c.x >= size(\map) || c.y >= size(\map[0])){ 
		return false;
	}
	str target = \map[c.x][c.y];
	return target == "f" || target == "e" || target == "x"
		|| target == "d" || target == "s" || target == "g"
		|| target == "t"; //not ideal
}

private Coordinates getRight(Coordinates c){ return <c.x, c.y + 1>; }
private Coordinates getLeft (Coordinates c){ return <c.x, c.y - 1>; }
private Coordinates getDown (Coordinates c){ return <c.x + 1, c.y>; }
private Coordinates getUp   (Coordinates c){ return <c.x - 1, c.y>; }


private Coordinates maxy(Coordinates a, Coordinates b){
	return a.y > b.y ? a : b;
}

private Coordinates maxx(Coordinates a, Coordinates b){
	return a.x > b.x ? a : b;
}

public int getMaxY(set[Coordinates] coords){
	return (<0,0> | maxy(it,e) | Coordinates e <- coords)[1]; 
	//this is a reducer
}

public int getMaxX(set[Coordinates] coords){
	return (<0,0> | maxx(it,e) | Coordinates e <- coords)[0]; 
}





