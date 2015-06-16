# Flip4Mac #

The current Flip4Mac (**2.3.0.14**) that supports Snow Leopard brings a new setting that allows applications to load WMV files in the background. [See this page](http://www.telestream.net/telestream-support/flip4mac-wmv/faq.htm#3).

However, this setting doesn't work really well for Skreenics. The application loads the file entirely, to calculate duration and capture all necessary frames. However, Flip4Mac tells Skreenics the files is entirely loaded when actually it is not, and it creates thumbnails of videos as if they were 10 seconds long.

# Solution #

The simplest (and only, AFAIK) solution is to add Skreenics to the list of applications that should load the file entirely before playback.

To do that, simply go to "System Prefrences" > Flip4Mac > "Player" tab > "Advanced ...". There, click the (+) button and add Skreenics. Make sure the "Show Progress" checkbox is checked if you want to see the usual video loading window.