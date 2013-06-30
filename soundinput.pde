import pitaru.sonia_v2_9.*;
import SoniaHelper.*;

int spectrumLength=256; //256 Needs to be power of 2
int bandsteps;
float maxdist,damperval;
SoniaHelper ffthelper;
float pt[];

float rad;



public void doSoundInput() {
  LiveInput.getSpectrum();
  ffthelper.update(LiveInput.spectrum);
}
