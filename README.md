# Roland Ripcord

This was written for Roland J-6 firmware v1.02

This is a truly terrible script I use to make sure my Roland J-6 properly
connects to my midi-thru device on my laptop. This isn't really an issue with
Mac (though it appears sometimes you need to reboot the device) or Windows, but
with Linux there appears to be an issue whereby you need to immediately read
from the device the moment it boots/registers.

## Usage

Just run the script like so:

```bash
chmod 750 roland-ripcord
./roland-ripcord
```

When the device connects it will state that it's verifying liveness. Once
enough clock messages are sent, it'll autoconnect to whatever the MIDI through
device is on your system (it's assuming there is only one with a hardcoded name
based purely off of my own setup).

## Disclaimers

I've not used many MIDI devices, so perhaps this is just the name of the game.
Out of the three I currently own, the J-6 is the only one that just doesn't
let me read from it if there's any delay after starting it. Furthermore if I
stop reading from it at any point, it will refuse to continue giving me MIDI
data.

This thing probably has some bugs in it. Oh well. This is mostly for personal
use, but might be useful for the 0.0000001% of other people who might run into
this problem. Maybe I just have a faulty device. Who knows!
