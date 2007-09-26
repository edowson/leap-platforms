#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <sys/select.h>
#include <sys/types.h>
#include <signal.h>

#include "hybrid-fp-sw.h"

// service instantiation
FRONT_PANEL_CLASS   frontPanelInstance;
RRR_SERVICE_CLASS  *FRONT_PANEL_service = &frontPanelInstance;

// constructor
FRONT_PANEL_CLASS::FRONT_PANEL_CLASS()
{
}

// destructor
FRONT_PANEL_CLASS::~FRONT_PANEL_CLASS()
{
    Uninit();
}

// init
void
FRONT_PANEL_CLASS::Init(
    HASIM_SW_MODULE     p,
    int                 ID)
{
    // set service ID and parent pointer
    serviceID = ID;
    parent = p;

    /* unfortunately, Perl doesn't play nice with binary
     * data, so we cannot simply instantiate a Perl front panel and
     * be done with it; we have to translate the incoming data into
     * ASCII and pipe the translated stream through to the dialog
     * box; this means we'll need to create another process for
     * the dialog box */
    if (pipe(child_to_parent) < 0 || pipe(parent_to_child) < 0)
    {
        parent->CallbackExit(1);
    }

    dialogpid = fork();
    if (dialogpid == 0)
    {
        // child
        close(child_to_parent[0]);
        close(parent_to_child[1]);

        dup2(parent_to_child[0], STDIN);
        dup2(child_to_parent[1], STDOUT);

        execlp("hasim-front-panel", "hasim-front-panel", NULL);
    }
    else
    {
        // parent
        close(child_to_parent[1]);
        close(parent_to_child[0]);

        // initial state
        childAlive = true;
        inputCache = 0;
        outputCache = 0;
        outputDirty = false;
    }
}

// uninit
void
FRONT_PANEL_CLASS::Uninit()
{
    if (childAlive)
    {
        // kill dialog box
        kill(dialogpid, SIGTERM);
        childAlive = false;
    }
}

// request
bool
FRONT_PANEL_CLASS::Request(
    UINT32 arg0,
    UINT32 arg1,
    UINT32 arg2,
    UINT32 *result)
{
    // we *could* sync state, but shouldn't be necessary

    // update cache and set dirty bit
    if (outputCache != arg0)
    {
        outputCache = arg0;
        outputDirty = true;
    }

    // return state from input cache
    *result = inputCache;
    return true;
}

// poll
void
FRONT_PANEL_CLASS::Poll()
{
    if (outputDirty)
    {
        syncOutputs();
        outputDirty = false;
    }

    syncInputs();
}

// internal helper method: sync input cache state with dialog box
void
FRONT_PANEL_CLASS::syncInputs()
{
    int     data_available;
    fd_set  readfds;
    struct timeval timeout;

    int read_from_dialog = child_to_parent[0];

    // read from pipe coming from dialog box and update input cache
    do
    {
        FD_ZERO(&readfds);
        FD_SET(read_from_dialog, &readfds);     // from dialog box

        timeout.tv_sec  = 0;
        timeout.tv_usec = SELECT_TIMEOUT;

        data_available = select(read_from_dialog + 1, &readfds,
                                NULL, NULL, &timeout);

        if (data_available == -1)
        {
            perror("select");
            parent->CallbackExit(1);
        }

        if (data_available != 0)
        {
            // incoming!
            int bytes_requested;
            int bytes_read;

            // sanity check
            if (data_available > 1)
            {
                fprintf(stderr, "activity detected on too many descriptors\n");
                parent->CallbackExit(1);
            }

            if (FD_ISSET(read_from_dialog, &readfds))
            {
                // incoming data from dialog box: convert to binary
                UINT32      mask;
                int         i;
                UINT32      data;
                char        asciibuf[DIALOG_PACKET_SIZE * 8];
                int         nbytes;

                nbytes = read(read_from_dialog, asciibuf, DIALOG_PACKET_SIZE * 8);
                if (nbytes == 0)
                {
                    // EOF => Exit button was pressed
                    parent->CallbackExit(0);
                }
                
                assert(nbytes == DIALOG_PACKET_SIZE * 8);

                mask = 1;
                data = 0;
                for (i = 0; i < DIALOG_PACKET_SIZE * 8; i++)
                {
                    if (asciibuf[i] == '1')
                    {
                        data += mask;
                    }
                    mask = mask << 1;
                }

                // update cache
                inputCache = data;
            }
            else
            {
                fprintf(stderr, "activity detected on unknown descriptor\n");
                parent->CallbackExit(1);
            }
        }
    }
    while (data_available != 0);
}

// internal helper method: sync output cache state with dialog box
void
FRONT_PANEL_CLASS::syncOutputs()
{
    UINT32      mask;
    int         i;
    char        asciibuf[DIALOG_PACKET_SIZE * 8];
    int         nbytes;

    int write_to_dialog  = parent_to_child[1];

    // convert to ASCII
    mask = 1;
    for (i = 0; i < DIALOG_PACKET_SIZE * 8; i++)
    {
        char bit = (mask & outputCache) ? '1' : '0';
        asciibuf[i] = bit;
        mask = mask << 1;
    }

    // send translated data to dialog box
    nbytes = write(write_to_dialog, asciibuf, DIALOG_PACKET_SIZE * 8);
    assert(nbytes == DIALOG_PACKET_SIZE * 8);
}
