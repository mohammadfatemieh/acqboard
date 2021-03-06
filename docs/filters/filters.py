#!/usr/bin/python
"""
   Analysis of all system filter parameters

   Generates necessary plots, as well. 

an explanation of why the bessel cutoff isn't exactly -3 db

http://groups-beta.google.com/group/comp.soft-sys.matlab/msg/f96918240a97fbe6?dmode=source&hl=en



"""

import fxquant
from matplotlib.pylab import *


kHzFormatter = FuncFormatter(lambda x, pos: "%d" % (x/1000))
class ADFilter:
    def __init__(self):
        self.cutoff3db = None
        self.Fs = None
        self.dsN = None
        self.poles = None
        self.f = None
        self.h = None
        self.fbits = None

class filters:
    
    def __init__(self, ad, name):
       
        """
        A class that plots the interesting filters for a combined
        analog-digital conversion system.
        
        """
        cutoff3db = ad.cutoff3db 
        self.wc = cutoff3db
        self.poles = ad.poles
        self.f = ad.f
        
        self.Fs = ad.Fs
        self.dsN = ad.dsN
        self.hfloat = ad.h
        self.fbits = ad.fbits
        self.fxquant = fxquant.fxquant(self.fbits)
        
        self.h = array(self.fxquant.toInts(self.hfloat), Float)/(2**(self.fbits -1))
        self.name = name

    def saveh(self):
        """ Saves the quantized filter to name.firdat,
        as a long list of integers"""

        fid = file(self.name + ".firdat", 'w')
        for x in self.h:
            fid.write("%d\n" % int(round(x * 2**(self.fbits -1))))
            
        fid.close()

    def plotanalog(self, save = False):
        
        fstart = 1000
        fstop = 250000
        fr = logspace(log10(fstart), log10(fstop), 10000)
        s = fr*1j

        hf = polyval(self.f[0], s)/polyval(self.f[1], s)

        mag = abs(hf)

        phase = unwrap(angle(hf))*180/pi;

        # TOTAL FREQUENCY RESPONSE ##########################
        figure(1)
        semilogx(fr, log10(mag)*20, 'b', linewidth=1.0)

        plot([self.Fs/2, self.Fs/2], [0, -110], 'r')
        plot([self.wc, self.wc], [0, -110], 'r')
        axis([fstart, fstop, -110, 0])
        xlabel('Frequency (kHz)')
        ylabel('Magnitude (dB)')
        title('Frequency Response of analog filters')
        ax=gca()
        ax.xaxis.set_major_formatter(kHzFormatter)
        ax.xaxis.grid(True, which="minor")
        ax.xaxis.grid(True, which="major")
        ax.yaxis.grid(True)
        
     
        if save:
            savefig(self.name + ".analog.freqres.svg")
            
        # PASSBAND RESPONSE
        figure(2)
        semilogx(fr, log10(mag)*20, 'b', linewidth=1.0)
        
        plot([self.Fs/2, self.Fs/2], [0, -110])
        axis([fstart, 10000, -6, 3])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
        title('Passband Frequency Response of analog filters')
        
        ax=gca()
        #ax.xaxis.set_minor_locator(MultipleLocator(5))
        ax.xaxis.set_major_locator(MultipleLocator(1000))
        ax.xaxis.set_major_formatter(kHzFormatter)
        ax.xaxis.grid(True, which="major")

        ax.yaxis.set_major_locator(MultipleLocator(1))
        ax.yaxis.grid(True)
        
        if save:
            savefig(self.name + ".analog.pass.svg")



        figure(3)
        semilogx(fr, log10(mag)*20, 'b', linewidth=1.0)

        plot([self.Fs/2, self.Fs/2], [0, -110])
        axis([12000, fstop, -110, -70])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
        title('Stopband Frequency Response of analog filters')

        ax = gca()
        ax.xaxis.grid(True, which="major")
        ax.xaxis.grid(True, which="minor")
        ax.yaxis.grid(True, which="major")


        if save:
            savefig(self.name + ".analog.stop.svg")

        # GROUP DELAY ##################################
        grd = -phase/fr/360*1e6
        
        figure(4)
        semilogx(fr, grd, linewidth=1.0)
        
        ylabel(r'Group Delay (us$)') 
        xlabel('Frequency (kHz)') 
        ax = gca()
        ax.xaxis.set_major_formatter(kHzFormatter)
        ax.xaxis.grid(True, which="major")
        ax.xaxis.grid(True, which="minor")
        ax.yaxis.grid(True, which="major")
          
        axis([1000, 100000, 5, 40])
        
        title('Group delay of analog filters')
        if save:
            savefig(self.name + ".analog.grd.svg")

        if not save:
            show()

    def plotquant(self, save=False):
        w = linspace(0, pi, 5000*self.dsN);
        H = signal.freqz(self.hfloat, [1.0], w)
        Hq = signal.freqz(self.h, [1.0], w)
        flin = w/pi*self.Fs/2;
        plot(flin/1000, 20*log10(abs(H[1])), 'b', label="Floating point")
        plot(flin/1000, 20*log10(abs(Hq[1])), 'r', label="22 bit fixed-point")
        xlabel('Frequency (kHz)')
        ylabel('Magnitude (dB)')
        title('Quantization effects on FIR frequency response')
        legend()
        grid(1)
        if save:
            savefig(self.name + ".digital.quant.svg")
        else:
            show()
        
    def plotdigital(self, save=False):
        # uniting analog and digital
        # first, we convert the analog response into the corresponding digital        # frequency response

        
        w = linspace(0, pi, 5000*self.dsN);
        flin = w/pi*self.Fs/2;
        slin = flin*1j; 
        totalaf = self.f

        hanalog = polyval(totalaf[0], slin)/polyval(totalaf[1], slin)

        H = signal.freqz(self.h, [1.0], w)
        
        figure(5)
        plot(flin/1000, 20*log10(abs(H[1])), 'g', label = "FIR response")
        plot(flin/1000, 20*log10(abs(hanalog)), 'r', label = "Analog response")
        Y = abs(H[1])*abs(hanalog)
        plot(flin/1000, 20*log10(Y), 'b', label = "Total Frequency Response")

        grid(1)
        plot([10, 10], [-200,10], 'k--', label = "_nolegend_");
        plot([16, 16], [-200,10], 'k--', label = "_nolegend_");
        ylabel('Magnitude (dB)'); 
        xlabel('Frequency (kHz)'); 
        title(r'$\rm{Undecimated Aggregate Spectra}Y(e^{j\omega})$')
        axis([0, 96, -180, 10])
        legend()
        if save:
            savefig(self.name + ".digital.aggregate.svg")
        

        # now zoom in on the passband
        figure(6)
        plot(flin/1000, 20*log10(abs(H[1])), 'g', label = "FIR response")
        plot(flin/1000, 20*log10(abs(hanalog)), 'r', label = "Analog response")
        
        plot(flin/1000, 20*log10(Y), 'b', label = "Total Frequency Response")

        grid(1)

        ylabel('Magnitude (dB)'); 
        xlabel('Frequency (kHz)'); 
        title(r'$\rm{Undecimated Aggregate Spectra}Y(e^{j\omega})$')
        axis([0, 10, -3, 3])
        legend()
        
        if save:
            savefig(self.name + ".digital.pass.svg")




        # now plot the downsampled total spectra
        figure(7)
        # P = abs(H[1]) is this really what we want?
        P = Y
        P.shape = (self.dsN, size(Y)/self.dsN)
        flin.shape = (self.dsN, size(flin)/self.dsN)
        plot(flin[0, :]/1000, 20*log10(P[0, :]), 'b')
        grid(1)
        plot(flin[0, :]/1000, 20*log10(sum(P[1:8, ::-1])), 'r')
        xlabel('Freqency (kHz)')
        ylabel('Magnitude (dB)')
        plot(flin[0, :]/1000, r_[[-96]*len(flin[0,:])], 'g',
             label = "_nolegend_")
        title('Total decimated frequency response, with aliases')
        legend(('Signal', 'Aliases'))
        if save:
            savefig(self.name + ".digital.withaliases.svg")

        if not save:
            show()

def find3db(co, poles):
    cutoff3db = co
    wc = cutoff3db
    
    f = signal.bessel(poles, wc, analog=1)

    (w, h) = signal.freqs(f[0], f[1], linspace(1000, 30000, 100))

    h = abs(h)
    hlog = 20*log10(h)

    err = 1000000;
    minf = 0
    for i in range(len(hlog)):
        e = (hlog[i] - 20*log10(1/sqrt(2)))**2 
        if e < err:
            err = e
            minf = i
            
    return (co, w[minf], hlog[minf], co/w[minf])
    
  
from scipy import *


def main():

    ad = ADFilter
    
    ad.cutoff3db = 13500
    ad.Fs = 192000
    ad.dsN = 6
    ad.poles = 8 
    ad.f = signal.bessel(8,
                         ad.cutoff3db*(1.27 + .213*(ad.poles/2-1)),
                         analog=1)
    ad.fbits = 22
    ad.h = signal.remez(143,
                        r_[0, 10000,  16000, ad.Fs/2 -1],
                        [1,  0 ],
                        r_[0.5,  500],
                        Hz=ad.Fs,
                        maxiter=1000);
    
    y = filters(ad, name="soma-1")
    save = True
    y.plotanalog(save=save)
    y.plotdigital(save=save)
    y.plotquant(save=save)
    y.saveh()




        
if __name__ == "__main__":
    main()
    
