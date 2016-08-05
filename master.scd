//William Morris - Computer Music: Task 1 - A Basic Subtractive Synthesizer


//------------------------------------------------------------
//run synthdef first, then the GUI below.
//------------------------------------------------------------

(
SynthDef(\osc1, {

	arg waveform1, waveform2, freq=440, amp=0.1, detune1=1, detune2=1,
 	gate=1, bw=1, rq=1, a=0.01, d=0.3, s=0.5, r=1, cutoff=100, rez=0, fEnvAmount=3000;

	var oscillator1, oscillator2, oscChoices1, oscChoices2;
	var detuneFreq1, detuneFreq2, signalCombined, envAmpAdsr, envelopedSound, filteredSound, envFilterAdsr, pannedOsc, synth;

	detuneFreq1 = freq*detune1;

	detuneFreq2 = freq*detune2;

	//my choice of wave shape was purely subjective, and I hoped to use more intriguing oscillator types to create a more unique subtractive synthesizer.

	oscChoices1 = [SinOsc.ar(detuneFreq1),Saw.ar(detuneFreq1),Pulse.ar(detuneFreq1)];

	oscChoices2 = [SinOsc.ar(detuneFreq2),Blip.ar(detuneFreq2),LFTri.ar(detuneFreq2)];

	//instead of choosing the waveform individually using a drop down menu, the SelectX object allows the output to be mixed from an array of inputs, performing a crossfade between two adjacent waves. This allows crossfade between oscillators.

	oscillator1 = SelectX.ar(waveform1, oscChoices1);

	oscillator2 = SelectX.ar(waveform2, oscChoices2);

	signalCombined = oscillator1 + oscillator2;

	envFilterAdsr = EnvGen.kr(Env.adsr(a, d, s, r), gate)*fEnvAmount;

	filteredSound = MoogFF.ar(signalCombined, cutoff+envFilterAdsr, rez);

	envAmpAdsr = EnvGen.kr(Env.adsr(a, d, s, r), gate);

	envelopedSound = filteredSound * envAmpAdsr * amp;

	pannedOsc = Pan2.ar(envelopedSound, 0);

	Out.ar(0, pannedOsc);
}	).add;
)

//------------------------------------------------------------
//now run this
//------------------------------------------------------------


(
var window, waveform1Knob, waveform2Knob, freqKnob, ampKnob, detune1Knob, detune2Knob, ampSlider, attackSlider, decaySlider, sustainSlider, releaseSlider, filterEnvAmount, bStartstop, gateButton, cutoffKnob, rezKnob;

var setDefault, waveform1label, waveform2label, filterTitle, detuneTitle, frequencyOutputlabel, oscillatorTitle, envelopeTitle;

var synth;

w = Window.new("GUItryout", Rect(50, 50, 750, 430));
Font("OCR A Std", 12).setDefault;
synth = Synth(\osc1, [\gate, 0 ]);

w.view.background = Color.new255(85, 107, 47);

w.drawFunc = {
	Pen.fillColor = Color.new255(85, 107, 47);
    Pen.moveTo(10@10);

	Pen.lineTo(10@420);
    Pen.lineTo(740@420);
    Pen.lineTo(740@10);
    Pen.lineTo(10@10);

	Pen.moveTo(160@30);
	Pen.lineTo(160@410);

	Pen.moveTo(300@30);
	Pen.lineTo(300@410);

	Pen.moveTo(450@30);
	Pen.lineTo(450@410);

    Pen.draw(4);
};

oscillatorTitle = StaticText(w, Rect(15, 340, 100, 100));
oscillatorTitle.font = Font("OCR A Std", 18);
oscillatorTitle.string = "OSCS";

detuneTitle = StaticText(w, Rect(180, 340, 100, 100));
detuneTitle.font = Font("OCR A Std", 18);
detuneTitle.string = "DETUNE";

filterTitle = StaticText(w, Rect(325, 340, 100, 100));
filterTitle.font = Font("OCR A Std", 18);
filterTitle.string = "FILTER";

frequencyOutputlabel = StaticText(w, Rect(480, 340, 200, 100));
frequencyOutputlabel.font = Font("OCR A Std", 18);
frequencyOutputlabel.string = "FREQUENCY + OUTPUT";

envelopeTitle = StaticText(w, Rect(540, 120, 200, 100));
envelopeTitle.font = Font("OCR A Std", 18);
envelopeTitle.string = "ADSR ENV";

waveform1Knob = EZKnob(w, Rect(45, 25, 100, 100), "SAW", ControlSpec(0.01, 2, \lin),
	{|waveform1| synth.set(\waveform1, waveform1Knob.value); }, 1);

waveform1label = StaticText(w, Rect(15, 50, 70, 90));
waveform1label.string = "SINE";
waveform1label = StaticText(w, Rect(110, 50, 70, 90));
waveform1label.string = "PULSE";

waveform2Knob = EZKnob(w, Rect(45, 260, 100, 100), "BLIP", ControlSpec(0.01, 2, \lin),
	{|waveform2| synth.set(\waveform2, waveform2Knob.value); }, 1);

waveform2label = StaticText(w, Rect(15, 280, 70, 90));
waveform2label.string = "SINE";
waveform2label = StaticText(w, Rect(110, 280, 70, 90));
waveform2label.string = "LFTRI";

freqKnob = EZKnob(w, Rect(465, 240, 100, 120), "FREQUENCY", ControlSpec(20, 16000, \exp),
	{|freqKnob|synth.set(\freq, freqKnob.value); }, 100);

ampKnob = EZKnob(w, Rect(600, 240, 100, 120), "OUTPUT", ControlSpec(0.1, 1, \lin),
	{|ampknob| synth.set(\amp, ampKnob.value); }, 0.3);

//the argument for 'warp' here follows an exponential curve because I wanted a slower increase of the envelope values:

filterEnvAmount = EZKnob(w, Rect(325, 260, 100, 100), "FILTER ENV", ControlSpec(0.01, 4000, \lin),
	{|ampknob| synth.set(\fEnvAmount, ampKnob.value); }, 1000);

attackSlider = EZSlider(w, Rect(460, 30, 260, 25), "ATTACK", ControlSpec(0.01, 20, \exp),
	{|attackSlider| synth.set(\a, attackSlider.value); }, 2);

decaySlider = EZSlider(w, Rect(460, 60, 260, 25), "DECAY", ControlSpec(0.01, 20, \exp),
	{|decaySlider| synth.set(\d, decaySlider.value); }, 1.5);

sustainSlider = EZSlider(w, Rect(460, 90, 260, 25), "SUSTAIN", ControlSpec(0.01, 1, \exp),
	{|sustainSlider| synth.set(\s, sustainSlider.value); }, 0.3);

releaseSlider = EZSlider(w, Rect(460, 120, 260, 25), "RELEASE", ControlSpec(0.01, 20, \exp),
	{|releaseSlider| synth.set(\r, releaseSlider.value); }, 0.05);

detune1Knob = EZKnob(w, Rect(180, 25, 100, 100), "DETUNE 1", ControlSpec(0.01, 1, \lin),
	{|detune1Knob| synth.set(\detune1, detune1Knob.value); }, 1);

detune2Knob = EZKnob(w, Rect(180, 260, 100, 100), "DETUNE 2", ControlSpec(0.01, 1, \lin),
	{|detune2Knob| synth.set(\detune2, detune2Knob.value); }, 1);

cutoffKnob = EZKnob(w, Rect(325, 25, 100, 100), "CUTOFF FREQ", ControlSpec(20, 16000, \exp),
	{|cutoffKnob| synth.set(\cutoff, cutoffKnob.value); }, 100);

rezKnob = EZKnob(w, Rect(325, 140, 100, 100), "RESONANCE", ControlSpec(0, 4, \lin),
	{|rezKnob| synth.set(\rez, rezKnob.value); }, 2);

bStartstop = Button(w, Rect(30, 170, 100, 50));
bStartstop.states = [["START", Color.white, Color.black],["STOP", Color.white, Color.black]];
bStartstop.action = {|view|
	if (view.value == 1) {
		synth.set(\gate, 1);
	};
	if (view.value == 0) {
		synth.set(\gate, 0);
	};
};

w.front;
)
