//////////////////////////////////////////////////////////////////////////////
//
// Part of Ludoscope Mini
// @brief   This file contains a wrapper for getting one rnadom element from a list
//			based on the seed. This is written because the takeonefrom function does 
//			not conform to its specifications and does not reproduce the same result
// @author  Georgia Samaritaki - samaritakigeorgia@gmail.com
// @date    28-1-202
//
//////////////////////////////////////////////////////////////////////////////
module utility::Arbitrary

import util::Math;
import Set;
import List;

public &T arbTakeOneFrom(list[&T] l) = l[arbInt(size(l))]; 

public &T arbTakeOneFrom(set[&T] l) = toList(l)[arbInt(size(l))];
	
