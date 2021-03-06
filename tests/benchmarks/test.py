#!/usr/bin/python
"""
This code creates a "test" of the acqboard, in the form of setting a bunch of parameters and actually recording the data


"""

import sys
import socket
import struct
from scipy import *
from matplotlib.matlab import *

sys.path.append("../acqboardcmd")
import acqboard
from acqboardcmd import *


sys.path.append("../SRSio")
import SRS


class FuncState:
    """ State of the function generator"""

    def __init__(self):
        self.amp = 0.0
        self.freq = 0.0
        self.mode = 0
        self.offset = 0.0
        

    def setmode(self, modestr):
        if modestr == "sine":
            self.mode = 0 
        elif modestr == "square":
            self.mode = 1
        elif modestr == "noise":
            self.mode = 2 
        elif modestr == "IMD":
            self.mode = 4
        else:
            print "INVALID MODE"


class AcqSocketOut:
    # actually handles the socket communication

    def __init__(self):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def open(self):
       self.s.connect("/tmp/acqboard.in")
        
    def send(self, str):
        outstr = str + "123456789012345678"
        self.s.send(outstr)
    def close(self):
        self.s.close()

class AcqSocketStat:
    # actually handles the socket communication

    def __init__(self):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def open(self):
        self.s.connect("/tmp/acqboard.status")

    def read(self):
        return self.s.recv(3)
    
    def close(self):
        self.s.close()


                
class AcqState:

    def __init__(self):
        self.gains = {}
        self.hpfs = {}
        
        for key in AcqBoardCmd.channames.keys():
            self.gains[key] = 0
            self.hpfs[key] = 0
        self.inchana = 0
        self.inchanb = 0
        self.mode = 0
        self.rawchan = 0

    def setmode(self, mode, rawchan=0):
        if mode == "normal":
            self.mode = 0
        elif mode == "offsetdisable":
            self.mode = 1
        elif mode == "simulatesample":
            self.mode = 2
        elif mode == "raw":
            self.mode = 3
            self.rawchan = rawchan

    
        
        

class Test:

    def __init__(self,  acqstate, funcstate):
        """

        """
        self.acqstate = acqstate
        self.funcstate = funcstate


    def configure(self):
        """ setup acqboard, then signal generator"""

        funcgen = SRS.SRSfunc(0)
        
        # first, disable function generator 
        funcgen.setoutputenable("off")

        # configure parameters:
        funcgen.setmode(self.funcstate.mode)

        funcgen.setamp(self.funcstate.amp)
        self.funcstate.amp = funcgen.amp  # update with actual set value

        funcgen.setfreq(self.funcstate.freq)
        self.funcstate.freq = funcgen.freq # update with actual, set value

        funcgen.setoffset(self.funcstate.offset)
        self.funcstate.offset = funcgen.offset
        

        # now, the acqboard:
        acqout = AcqSocketOut()
        acqout.open()
        acqstat = AcqSocketStat()
        acqcmd = AcqBoardCmd()
        acqstat.open()        
        
        # first, set mode
        acqout.send(acqcmd.switchmode(self.acqstate.mode, \
                                      self.acqstate.rawchan))

        tmpcmdid = -1
        while tmpcmdid != acqcmd.cmdid:
            stat = unpack("BBB", acqstat.read())
            tmpcmdid = stat[1]/2

        print "mode set"
        
        # then, set gain for each channel

        for i in AcqBoardCmd.channames.keys():
            
            acqout.send(acqcmd.setgain(i, self.acqstate.gains[i]))
            tmpcmdid = -1
            while tmpcmdid != acqcmd.cmdid:
                stat = unpack("BBB", acqstat.read())
                tmpcmdid = stat[1]/2

            acqout.send(acqcmd.sethpfilter(i, self.acqstate.hpfs[i]))
            tmpcmdid = -1
            while tmpcmdid != acqcmd.cmdid:
                stat = unpack("BBB", acqstat.read())
                tmpcmdid = stat[1]/2

        print "filters and gains set"
        
        
        
        # reenable function generator
        funcgen.setoutputenable("on")
        


    def rawrun(self, nsamples):
        """ Collect nsamples of data running in raw mode """

        self.configure()

        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        
        
        s.connect("/tmp/acqboard.out")


                
        nsamp = 0; 
        
        resultstr = ""
        sample = s.recv(512)


        while (nsamp < (2*nsamples*24.0/16.0 + 200)):
            tmpstr =s.recv(1024)
            nsamp += len(tmpstr)
            resultstr += tmpstr

        offset = 20
        datastr = resultstr[offset:]

        

        # now, we format
        data = zeros(nsamples, Int16)

        pos = 0
        for i in range(len(datastr)/2):

            #print i, len(datastr), len(datastr)/2, pos
            if i % 12 < 8 :
                if pos < nsamples:
                    data[pos] = unpack(">h", datastr[(2*i):(2*(i+1))])[0]
                    pos += 1             
                
        s.close()
        return data


def main():
    f = FuncState()
    f.setmode("IMD")
    f.freq = (964.84375, 2894.53125)
    f.amp = (0.020, 0.020)


    a = AcqState()
    a.setmode("raw")
    a.rawchan = 'A1' 
    a.gains['A1'] = 100
    
    t = Test(a,f)

    plot(t.rawrun(200000))
    show()
    
    

if __name__ == "__main__":

    main()



    
