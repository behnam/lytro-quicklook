# Lytro "Quick Look" Plugin
This is my experimental Quick Look plugin for Lytro images, so it's for Mac OS X only. It enables the Finders' Quick Look feature for shareable Light Field Pictures. 

## Installation
I've uploaded the source code here, as well as the generated binary *.qlgenerator for people who want to just want to use it, available at the downloads section.

To install simply copy the binary `Lytro.qlgenerator` to `~/Library/QuickLook/` and restart. If you don't want to restart you can also try `qlmanage -r` in the Terminal.app to reset the Quick Look daemon. 

> Source Code is also available and just do whatever you want with it, it's very messy as I'm not experienced with Cocoa/Objective-C. Maybe someone with more experience wants to help make it better, or even help with an interactive Quick Look Preview?

## More Details
There are two kinds of Light Field Picture files, this plugin only works with the second kind (with -stk appended to its filename).

1. *.lfp file (~16MB)
2. *-stk.lfp files (~1MB)

> -stk.lfp files contain multiple JPEG files, metadata in JSON format and a lookup table to help you determine which image has which focus. Lytro creates this file automatically when importing from your camera as it is easier to share online.
