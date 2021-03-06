//
// Copyright (c) 2014, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <strings.h>
#include <assert.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <iostream>

#include "platforms-module.h"
#include "default-switches.h"

#include "awb/provides/unix_pipe_device.h"
#include "awb/provides/physical_platform_defs.h"


using namespace std;

extern GLOBAL_ARGS globalArgs;

// ============================================
//           UNIX Pipe Physical Device
// ============================================

// ============================================
//           Class static functions
// These functions are necessary to ensure that the
// class constructor is non-blocking. 
// ============================================

void * UNIX_PIPE_DEVICE_CLASS::openReadThread(void *argv) {
    UNIX_PIPE_DEVICE_CLASS *objectHandle = (UNIX_PIPE_DEVICE_CLASS*) argv;

    int retries = 0;
    string readFile(objectHandle->ioFile + "_FROM"); 

    do
    {
        objectHandle->inpipe[0] =  open(readFile.c_str(), O_RDONLY);
        retries ++;
        sleep(1);
    } while ((objectHandle->inpipe[0] < 0) && (retries < 120));

    if(objectHandle->inpipe[0] < 0) 
    {
        fprintf(stderr, "CPU Timed out waiting for %s, transfers on this line result in deadlocks\n", readFile.c_str());
        exit(1);
    }

    objectHandle->initReadComplete = 1;

}

void * UNIX_PIPE_DEVICE_CLASS::openWriteThread(void *argv) {
    UNIX_PIPE_DEVICE_CLASS *objectHandle = (UNIX_PIPE_DEVICE_CLASS*) argv;
    string writeFile(objectHandle->ioFile + "_TO"); 

    // create write side first
    mkfifo(writeFile.c_str(), S_IWUSR | S_IRUSR | S_IRGRP | S_IROTH);

    // This should block...
    // maybe we need to wait a while for the FPGA to come up.
    objectHandle->outpipe[1] = open(writeFile.c_str(), O_WRONLY);

    if (objectHandle->ParentWrite() < 0)
    {
       printf("Failed trying to open %s.  Are you using a network share? If so, set environment variable LEAP_EXECUTION_DIRECTORY to a non-network location.\n", writeFile.c_str());

       perror("output pipe WriterThread");
       exit(1);
    }

    objectHandle->initWriteComplete = 1;

}


// ============================================
//           Class member functions
// ============================================

// constructor: set up hardware partition
UNIX_PIPE_DEVICE_CLASS::UNIX_PIPE_DEVICE_CLASS(
    PLATFORMS_MODULE p) :
        bluesimSwitches(),
        PLATFORMS_MODULE_CLASS(p),
        initReadComplete(),
        initWriteComplete(),
        childAlive(),
        ioFile() 
{
    initReadComplete = 0;
    initWriteComplete = 0;
    childAlive = false;
    logicalName = NULL;
    deviceSwitch = new COMMAND_SWITCH_DICTIONARY_CLASS("DEVICE_DICTIONARY");
}

// destructor
UNIX_PIPE_DEVICE_CLASS::~UNIX_PIPE_DEVICE_CLASS()
{
    // cleanup
    Cleanup();
}

void
UNIX_PIPE_DEVICE_CLASS::Init()
{

    string executionDirectory = "";
    char * leapExecutionDirectory = getenv("LEAP_EXECUTION_DIRECTORY");

    // Newer builds will tell us where the pipes file is
    // located. Let's find out. 
    if (leapExecutionDirectory != NULL)
    {
       executionDirectory = leapExecutionDirectory;
    }

    // Let's find out what our file target is
    if ((logicalName != NULL) && (deviceSwitch->SwitchValue(*logicalName) != NULL))
    {
        ioFile = executionDirectory + "/pipes/" + *(deviceSwitch->SwitchValue(*logicalName));
    }
    else if((logicalName != NULL) && (*logicalName == FPGA_PLATFORM_NAME))
    {  
        // backwards compatible support for old-style RRR. 
        ioFile = executionDirectory + "/pipes/" + *logicalName;
    }
    else 
    {
        // This device is not being used. No initialization necessary...
        return;
    }

    fflush(stdout);
    string commDirectory = executionDirectory + "/pipes/";
    
    if (mkdir(commDirectory.c_str(), S_IRWXU) != 0) 
    {
        if (errno != EEXIST)
        {
            fprintf(stderr, "Comm directory creation failed, bailing\n");
            exit(1);
        }
    }


    // Invoke threads for opening the I/O channels. This allows the
    // constructor to terminate.  However, subsequent I/O requests
    // will block until the initialization is complete.
    if (pthread_create(&ReaderThreads[0],
		       NULL,
		       openReadThread,
		       this))
    {
	perror("pthread_create, ReaderThread: ");
	exit(1);
    }

    if (pthread_create(&WriterThreads[0],
                       NULL,
                       openWriteThread,
                       this))
    {
      perror("pthread_create, WriterThread: ");
      exit(1);
    }

    childAlive = true;

}

// override default chain-uninit method because
// we need to do something special
void
UNIX_PIPE_DEVICE_CLASS::Uninit()
{

    // do basic cleanup
    Cleanup();

}

// cleanup: close the pipe.  The other side will exit.
void
UNIX_PIPE_DEVICE_CLASS::Cleanup()
{
    if (childAlive)
    {
        close(ParentRead());
        close(ParentWrite());
        childAlive = false;
    }
}

// probe pipe to look for fresh data
bool
UNIX_PIPE_DEVICE_CLASS::Probe()
{
    if (!initReadComplete) return false;

    // test for incoming data on physical channel
    struct timeval  timeout;
    int             data_available;
    fd_set          readfds;

    FD_ZERO(&readfds);
    FD_SET(ParentRead(), &readfds);

    timeout.tv_sec  = 0;
    timeout.tv_usec = SELECT_TIMEOUT;

    data_available = select(ParentRead() + 1, &readfds, NULL, NULL, &timeout);

    if (data_available == -1)
    {
        if ((errno == EINTR) || ! childAlive)
        {
            data_available = 0;
        }
        else
        {
            perror("unix-pipe-device select");
            exit(1);
        }
    }

    if (data_available != 0)
    {
        // incoming! sanity check
        if (data_available != 1 || FD_ISSET(ParentRead(), &readfds) == 0)
        {
            cerr << "unix-pipe: activity detected on unknown descriptor" << endl;
            exit(1);
        }

        // yes, data is available
        return true;
    }

    // no fresh data
    return false;

}

// blocking read
void
UNIX_PIPE_DEVICE_CLASS::Read(
    unsigned char* buf,
    int bytes_requested)
{
    while(!initReadComplete) 
    {
        sleep(1);
    }

    // assume we can read data in one shot
    int bytes_read = read(inpipe[0], buf, bytes_requested);

    // pipe read something funny, which implies that hardware process
    // has terminated or that we are in the process of tearing down
    // the software side.
    if (bytes_read != bytes_requested)
    {

        // Check to see if there's an uninit in progress, in which
        // case a short return value is expected.
        if (!UninitInProgress())
        {  
            cout << "Unexpected Read Short Count.  Did the simulation/FPGA terminate?" << endl; 
            CallbackExit(0);
        }

        // otherwise, kill this thread
        pthread_exit(NULL);
    }

}

// write
void
UNIX_PIPE_DEVICE_CLASS::Write(
    unsigned char* buf,
    int bytes_requested)
{
    while(!initWriteComplete) 
    {
        sleep(1);
    }

    // assume we can write data in one shot
    int bytes_written = write(outpipe[1], buf, bytes_requested);

    if (bytes_written != bytes_requested)
    {
        // Check to see if there's an uninit in progress, in which
        // case a short return value is expected.
        if (!UninitInProgress())
        {
            cout << "Unexpected Write Short Count.  Did the simulation/FPGA terminate?" << endl; 
            CallbackExit(0);
        }

        // otherwise, kill this thread
        pthread_exit(NULL);
    }
}

void UNIX_PIPE_DEVICE_CLASS::RegisterLogicalDeviceName(string name)
{
    logicalName = new string(name);
}


BLUESIM_SWITCH_CLASS::BLUESIM_SWITCH_CLASS() :
    bluesimArgc(0),
    bluesimArgv(new char *[1]),
    COMMAND_SWITCH_LIST_CLASS("bluesim")
{
    bluesimArgv[0] = NULL;
}

void
BLUESIM_SWITCH_CLASS::ProcessSwitchList(int switch_argc, char **switch_argv)
{
    bluesimArgc = switch_argc;
    delete [] bluesimArgv;
    bluesimArgv = switch_argv;
}

void
BLUESIM_SWITCH_CLASS::ShowSwitch(std::ostream& ostr, const string& prefix)
{
    ostr << prefix << "[--bluesim=\"<args>\"]    Arguments to Bluesim" << endl;
}

