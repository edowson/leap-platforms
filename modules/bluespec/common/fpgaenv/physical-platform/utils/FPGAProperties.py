##
## Copyright (c) 2015, Intel Corporation
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
## Redistributions of source code must retain the above copyright notice, this
## list of conditions and the following disclaimer.
##
## Redistributions in binary form must reproduce the above copyright notice,
## this list of conditions and the following disclaimer in the documentation
## and/or other materials provided with the distribution.
##
## Neither the name of the Intel Corporation nor the names of its contributors
## may be used to endorse or promote products derived from this software
## without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
##

import model

def numBuffersForDistance(distance, freq):
    """Calculate the number of buffer entries (FIFO slots) to insert in
    a latency-insensitive path to cover the distance travelled.
    """

    if (distance > 50):
        return 2
    return 0


def numPlatformLIChannelBufs(areaConstraints = None,
                             rootModuleName = None,
                             channelName = None):
    """The platform is currently composed of multiple area groups and the
    compiler has no way of knowing in which platform area group a channel
    terminates.  We use a heuristic for deciding when to insert buffers
    to handle wire delay.
    """
    freq = model.moduleList.getAWBParam('clocks_device', 'MODEL_CLOCK_FREQ')

    ## For now we are only interested in connections to the platform.  We
    ## should have a way to identify the platform.  Currently, look for
    ## "platform" in the name.
    if (rootModuleName.lower().count('platform') == 0):
        return 0

    if (freq >= 130):
        return 2
    if (freq >= 90):
        return 1
    return 0
