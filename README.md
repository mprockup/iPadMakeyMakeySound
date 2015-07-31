#Setting up MaKeyMaKey for the iPad

The MaKeyMaKey is designed to act as a keyboard and mouse when plugged into a computer. In order to use it for iPad we need to remap some of the inputs. Because the iPad cannot respond to mouse events, we want to remap some of those mouse parameters to more keyboard keys to be able to make use of all inputs.  

##Remapping MaKeyMaKey 

1. Install the Arduino dev tools:  https://learn.sparkfun.com/tutorials/installing-arduino-ide

2. Download MakeyMakey code: https://github.com/sparkfun/MaKeyMaKey

3. Open project in Arduino dev IDE: MaKeyMaKey-master/firmware/Arduino/makey_makey/makey_makey.ino
It should open a settings.h file as well as the makeymakey code.

4. Set to use "Arduino Leonardo” : Tools > Board > Arduino Leonardo

5. Set to use USB port for connection: Tools > Port > usb

6. To change key mappings:
  - There is a big array of key mappings in the settings.h file 
  - Edit the key codes in this array to remap the keys 
  - Hit the run button to install the changes.
  - Changes should take place immediately and persist until the next time you edit the settings

NOTE: When you plug it into the iPad, it will say "not supported” but should work anyway


###Suggested Keymap

- w, D5 = 'w'
- a, D4 = 'a'
- s, D3 = 's'
- d, D2 = 'd'
- f, D1 = 'f'
- g, D0 = 'g'
- click = 'c'
- space = ' '
- arrowL  = 'l'
- arrowR  = 'r'
- arrowU  = 'u'
- arrowD  = 'v'
- A5 = '5'
- A4 = '4'
- A3 = '3'
- A2 = '2'
- A1 = '1'
- A0 = '0'

## Using the iPad app 
With this application, you can connect a modified MaKey MaKey to an iPad and trigger sounds.

###Connecting the MaKeyMaKey

1. Modify the MaKeyMakey. Download the modified Arduino source and install on your MakeyMakey
2. Use the Apple Camera Connection Kit and attach a powered USB hub. The iPad cannot supply enough power to the MaKey MaKey, so a hub that has an external AC power source is requred.
3. Connect the MakeyMakey to one of the ports in that hub

###Using the app

- Touch a key on the MakeyMakey, you should see a light appear in a corresponding row in the table.
- Tap a row and select a sound. That sound will then be played each time you touch that key. (An indicator should turn green and last the length of the sound)
- Additional sounds can be added through iTunes File Sharing
  - Plug iPad to computer
  - Open iTunes and select the iPad icon on the top left
  - Select the Apps in the table on the right.
  - Scroll down to Filesharing and select MMSoundB
  - Drag in any sounds you want here (aiff, mp3, m4a, wav)
- The Makey Makey acts as a simple usb keyboard. You can trigger sonds in this app with a simple keyboard as well. Key presses are case sensitive.
- Swipe right on a row to remove the assigned sound.


This app was designed by Matthew Prockup and the Drexel App Lab as part of the Summer Music Technology program at Drexel University


Copyright (c) 2015 Matthew Prockup. All rights reserved.
