module utility::TileMap

import IO;
import List;

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

public set[tuple[int,int]] getAllCoordinates(
	Coordinates c, 
	tuple[int height,int width] size){ 
	
	set[tuple[int,int]] cset = {};
	for(int i <-[0..size.width])
		for(int j<-[0..size.height])
			cset += {<c.x + j, c.y + i>};
	return cset;
	//return [[<c.x + i, c.y + j> | int i <- [0 .. height]] | int j <- [0 .. width]];;
}

public lrel[int,int] findInMap(list[list[str]] \map, str toFind){
	return [<i,j> | int i <- [0..size(\map)], int j <- [0..size(\map[0])], \map[i][j] == toFind];
}

public list[Coordinates] getPath(list[list[str]] \map, str a, str b){
	list[Coordinates] ca = findInMap(\map,a), 
				cb = findInMap(\map,b);
	if(ca == [] || cb == []) return [];
	return getPath1(ca[0],cb[0],[],[],\map);
}

private str getTile(list[list[str]] \map, Coordinates c){
	if(c.x >= size(\map) || c.y >= size(\map[0])) return "";
	return \map[c.x][c.y];
}

private bool isReachable(Coordinates c, list[list[str]] \map){
	if(c.x > size(\map) || c.y > size(\map[0])) return false;
	str target = \map[c.x][c.y];
	return target == "f" || target == "e" || target == "x"; //not ideal
}

private Coordinates getRight(Coordinates c){ return <c.x,c.y+1>; }
private Coordinates getLeft (Coordinates c){ return <c.x,c.y-1>; }
private Coordinates getDown (Coordinates c){ return <c.x+1,c.y>; }
private Coordinates getUp   (Coordinates c){ return <c.x-1,c.y>; }

private list[Coordinates] getPath1(
						Coordinates current, 
						Coordinates target, 
						list[Coordinates] path,
						list[Coordinates] visited,
						list[list[str]] \map
						){
	println("current <current> target <target>");
	
	if(current == target)  return path;
	
	if(current in path) return [];
	if(current in visited) return [];
	path += [current];
	visited += [current];
	
	Coordinates r = getRight(current), l = getLeft(current),
				u = getUp(current), d = getDown(current);
	list[Coordinates] p1, p2, p3, p4;
	if(isReachable(r,\map)){
		p1 = getPath1(r,target,path,visited,\map);
		if(p1 != []) return p1;
	}
	if(isReachable(l,\map)) {
		p2 = getPath1(l,target,path,visited,\map);
		if(p2 != []) return p2;
	}
	if(isReachable(u,\map)) {
		p3 =  getPath1(u,target,path,visited,\map);
		if(p3 != []) return p3;
	}
	if(isReachable(d,\map)) {
		p4 =  getPath1(d,target,path,visited,\map);
		if(p4 != []) return p4;
	}
	return [];
}





