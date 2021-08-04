//////////////////////////////////////////////////////////////////////////////
//
// Function for matching pattern in a grid.
// @brief        This file contains the function for matching pattern 
//							 in a grid. Modified from Quinten's original version
// @contributor  Quinten Heijn - samuel.heijn@gmail.com - UvA
// @contributor  Georgia Samaritaki - UvA
// @date         20-04-2018 / 2-08-20
//
//////////////////////////////////////////////////////////////////////////////

module execution::Matching

import IO;
import List;
import util::Math;
import parsing::DataStructures;

public set[Coordinates] findPatternInGrid(TileMap grid, TileMap pattern)
{
	set[Coordinates] matches = {};
	int patternWidth = size(pattern[0]);
	int patternHeight = size(pattern);
	int gridHeight = size(grid);
	list[str] patternFirstLine = pattern[0];
	
	for (/[C*, [A*, patternFirstLine, B*], D*] := grid)
	{
		int widthOffset = size(A);
		int heightOffset = size(C);
		bool match = true;
		if (heightOffset + patternHeight <= gridHeight)
		{
			for (int row <- [heightOffset + 1 .. heightOffset + patternHeight])
			{
				if (pattern[row - heightOffset] != 
					grid[row][widthOffset .. widthOffset + patternWidth])
				{
					match = false;
					break;
				}
			}
			if (match)
			{
				matches += {<widthOffset, heightOffset>};
			}
		}
	}
	return matches;
}

public TileMap replacePattern(TileMap grid, TileMap pattern, Coordinates coordinates){
	int patternWidth = size(pattern[0]);
	int patternHeight = size(pattern);
	
	for (int i <- [0 .. patternWidth])
		for (int j <- [0 .. patternHeight])
			grid[j + coordinates.y][i + coordinates.x] = 
				pattern[j][i];
				
	return grid;		
}