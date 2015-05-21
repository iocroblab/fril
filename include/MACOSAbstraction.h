//  ---------------------- Doxygen info ----------------------
//! \file MACOSAbstraction.h
//!
//! \brief
//! Header file for simple OS-specific functions for abstraction (MacOS)
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


#ifdef __MACOS__

#ifndef __MACOSAbstraction__
#define __MACOSAbstraction__

#include <unistd.h>
#include <string.h>
#include <errno.h>

#ifndef  EOK
#define EOK				0
#endif

#ifndef  ETIME
#define ETIME			62
#endif

#ifndef  ENOTCONN
#define ENOTCONN		107
#endif

#ifndef  EALREADY
#define EALREADY		114
#endif

void delay(const int &TimeInMilliseconds);


int stricmp(const char *s1, const char *s2);





#endif

#endif
