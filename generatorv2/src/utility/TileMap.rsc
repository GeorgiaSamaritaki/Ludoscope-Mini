module utility::TileMap

import IO;
import List;

public list[list[str]] createTileMap(int width, int height, str symbol){
	return [[symbol | int i <- [0 .. width]] | int j <- [0 .. height]];
}

public void printTileMap(list[list[str]] \map){
	println("TileMap");
	for(list[str] row <- \map){
		println(row);
	}
}