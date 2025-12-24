# Roland Ripcord

This was written for Roland J-6 firmware v1.02

This is a truly terrible script I use to make sure my Roland J-6 properly
connects to my midi-thru device on my laptop. This isn't really an issue with
Mac (though it appears sometimes you need to reboot the device) or Windows, but
with Linux there appears to be an issue whereby you need to immediately read
from the device the moment it boots/registers.

## Usage

Just run the bash script with the MIDI connect command for connecting the J-6 to
your MIDI through device. For me this looks like:

```bash
bash ./roland-ripcord.sh aconnect 20:0 14:0
```

The J-6 interface is 20:0 and the MIDI through device is `14:0`.

When the device connects it will state that it's dumping the information from
the device, and at that point hit `Ctrl-C` to get the auto-connect to happen.

If you're just doing some debugging you can ommit the commands following the
script.

## Disclaimers

I've not used many MIDI devices, so perhaps this is just the name of the game.
Out of the three I currently own, the J-6 is the only one that just doesn't
let me read from it if there's any delay after starting it. Furthermore if I
stop reading from it at any point, it will refuse to continue giving me MIDI
data.

This thing probably has some bugs in it. Oh well. This is mostly for personal
use, but might be useful for the 0.0000001% of other people who might run into
this problem. Maybe I just have a faulty device. Who knows!
