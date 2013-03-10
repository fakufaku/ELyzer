ELyzer
======

A very simple processing sketch taking the Fourier transform of the audio input of the computer
and then controlling four digital outputs of an Arduino to display the spectrum.

This code replicates the demonstration of the [EL shield](http://www.seeedstudio.com/depot/el-shield-p-1287.html).

The `firmata` firmware is used for the bGeigie. You will also need to install the arduino library for Processing.
There are compatibility issues between the arduino library and Processing 2.0 beta. Use the latest stable version.
