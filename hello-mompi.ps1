Add-Type -AssemblyName System.Speech;
$synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer;
$message = "Hello Mompy. When you take a cold one?";
$synth.speak($message);
$synth.Dispose();  