#!/usr/bin/python

from numarray import *
import struct


class DataFile:
    def read(self, N):
        pass
    
class RawFile(DataFile):
    """ Read the acqboard out RAW file format, from the 24 byte
    output sequence.

    """

    
    def __init__(self, filename):
        self.filename = filename
        
        self.fid = file(filename, 'rb')

        # correct for file offset... wtf? 
        self.offset = 10
        self.fid.read(self.offset*2)

        self.pos = 0 

        
    def read(self, N):
        """ returns N shorts."""

        result = zeros( N, 'i2')
        
        
        for i in range(N):
            x = struct.unpack(">h", self.fid.read(2))

            if self.pos == 7:
                self.fid.read(4*2)
                self.pos = 0
            else:
                self.pos += 1

            result[i] = x[0]
            
            
        return result

    
class RegFile(DataFile):
    """ Read the acqboard out regular file format, from the 24 byte
    output sequence.

    """

    
    def __init__(self, filename, chan):
        self.filename = filename
        
        self.fid = file(filename, 'rb')

        # correct for file offset... wtf? 
        self.offset = 0
        self.fid.read(self.offset*2)

        self.pos = 0 
        self.chan = chan
        
    def read(self, N):
        """ returns N shorts."""

        result = zeros( N, 'i2')
        
        
        for i in range(N):
            framestr =  self.fid.read(24)
            bpos = self.chan*2
            wordstr = framestr[bpos:bpos+2]
            x = struct.unpack(">h", wordstr)[0]
            #print type(x)
            result[i] = x
            
        return result

    
import sys

#from matplotlib.matlab import *


def example():
    f = RawFile(sys.argv[1])
    
    for i in range(2**8):
        f.read(32768)



if __name__ == "__main__":
    example()