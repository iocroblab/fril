//  ---------------------- Doxygen info ----------------------
//! \file WindowsAbstraction.cpp
//!
//! \brief
//! Implementation file containing OS-specific functions (for debug purposes).
//!
//! \date December 2014
//!
//! \version 1.2
//!
//!	\author Torsten Kroeger, tkr@stanford.edu\n
//! \n
//! Stanford University\n
//! Department of Computer Science\n
//! Artificial Intelligence Laboratory\n
//! Gates Computer Science Building 1A\n
//! 353 Serra Mall\n
//! Stanford, CA 94305-9010\n
//! USA\n
//! \n
//! http://cs.stanford.edu/groups/manips\n
//! \n
//! \n
//! \copyright Copyright 2014 Stanford University\n
//! \n
//! Licensed under the Apache License, Version 2.0 (the "License");\n
//! you may not use this file except in compliance with the License.\n
//! You may obtain a copy of the License at\n
//! \n
//! http://www.apache.org/licenses/LICENSE-2.0\n
//! \n
//! Unless required by applicable law or agreed to in writing, software\n
//! distributed under the License is distributed on an "AS IS" BASIS,\n
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n
//! See the License for the specific language governing permissions and\n
//! limitations under the License.\n
//! 
//  ----------------------------------------------------------
//   For a convenient reading of this file's source code,
//   please use a tab width of four characters.
//  ----------------------------------------------------------

#include <OSAbstraction.h>

#if defined(WIN32) || defined(WIN64) || defined(_WIN64)

#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <Windows.h>
#include <stdlib.h>


ULONGLONG						StoredSystemTimeInTicks;


static bool						GetSystemTimeInSecondsCalledFirstTime	=	true;
	


// ****************************************************************
// WaitForKBCharacter()
//
unsigned char WaitForKBCharacter(bool *Abort)
{
	if (Abort == NULL)
	{
		while ( _kbhit() == 0 )
		{
			Sleep(10);
		}
	}
	else
	{
		while ( ( _kbhit() == 0 ) && (!(*Abort)) )
		{
			Sleep(10);
		}
		if (*Abort)
		{
			return(0);	
		}
	}
	
	return(_getche());
}



unsigned char CheckForKBCharacter(void)
{

	if ( _kbhit() == 0 )
	{
		return(0);	
	}
	else
	{
		return(_getche());
	}
}


float GetSystemTimeInSeconds(const bool &Reset)
{
	ULONGLONG				CurrentLocalMachineTime;

	if ( (GetSystemTimeInSecondsCalledFirstTime) || (Reset) )
	{
		StoredSystemTimeInTicks					=	GetTickCount64();
		GetSystemTimeInSecondsCalledFirstTime	=	false;
	}
	
	CurrentLocalMachineTime	=	GetTickCount64();

	return(0.001 * (float)(CurrentLocalMachineTime - StoredSystemTimeInTicks));
}

#endif
