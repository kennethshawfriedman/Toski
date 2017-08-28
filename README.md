# Schemer
A Prototype Debugging Tool for MIT Scheme

## Mac OS
![Preview](https://github.com/kennethshawfriedman/Schemer/blob/master/Photos%20and%20Videos/schemer-preview.gif?raw=true)

## Node.js
![Preview](https://github.com/kennethshawfriedman/Schemer/blob/master/Photos%20and%20Videos/node_schemer.gif?raw=true)

## This repo contains:

- SchemerForMacOS: The desktop IDE app project
- Node Schemer: A Node.js site for editing a Scheme notebook
- Playgrounds: just a few playgrounds for early prototyping of Mac-to-Scheme communication.
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

## Other

#### MacOS Version Restrictions
This app is written in Swift, so the lowest MacOS version possible is 10.9. However, it is currently set to a 10.10 minimum because of the use of a `viewDidLoad` method in an `NSViewController`. If anyone knows of a way to get the `viewDidLoad` functionality in 10.9 frameworks, let me know!
