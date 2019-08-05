# Toski
A Prototype Debugging Tool for MIT Scheme

![Preview](https://github.com/kennethshawfriedman/Toski/blob/master/Extras/Photos%20and%20Videos/Screen%20Shot%202019-06-19%20at%203.58.52%20PM.png?raw=true)

## This repo contains:

- Toski: The desktop IDE app project
- Extras: containing supplemental files & images (no code)

## Requirements:

Very simply, there are only two: the OS, and the language (dependencies considered harmful)

- MacOS, running 10.10 or higher (OS X Yosemite or higher)
    - and because it's a Cocoa Mac App, XCode is required to build the app (but not to run it)
- MIT-Scheme already installed. Follow installation instructions here: [MIT-Scheme from GNU][install]. The location of your installation *shouldn't* matter.

## How To Run

Assuming you are on Mac running a modern version of MacOS (10.10 or higher), and you have mit-scheme installed: simply launch the app as you would any other GUI.

You can download the fully built, GUI app here: [Schemer.app][release]

[release]: https://github.com/kennethshawfriedman/Schemer/releases/latest

## Naming

Toski is called Toski because Emacs is called Emacs.

## Building

This project should build with any reasonably recent version of XCode (it was written and tested on XCode 10).

_A note about stopping the Toski process_: Toski works by keeping an open pipe to an instance of MIT-Scheme. If you close the app normally, the pipe and the Scheme instance will stop. However, if you force-quit the app, or you use XCode to stop running a build of Toski, the MIT Scheme instance will continue running. Scheme will not like this, and it will start to use an unreasonable amount of CPU. If this happens, you can simply use Activity Monitor to force-quit processes that are called "mit-scheme-c". However the way to prevent this in the first place is to simply close out of the app, or Cmd-Q the app, instead of force-quitting it.