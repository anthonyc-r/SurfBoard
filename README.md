# SurfBoard
A desktop image board app.

Current state - Basic browsing and replying implemented. Noscript captcha and 4chan passes are supported!


## Media (e.g. webms)
By default this app makes use of NSWorkspace(and thus the GWorkspace app) to display media. For example clicking on a thumbnail will open whatever app handles the file type. So you can view webms, so long as you have an app to handle them. 
This can be disable in preferences to just use the apps own image viewer, however this doesn't support webm or animated gifs.

## Screenshots

![Board Index](/Screenshots/SurfBoard.png)
![Thread View](/Screenshots/Thread.png)
![Overview](/Screenshots/Overview.png)

Build using GNUstep. See [GNUstep](http://www.gnustep.org/developers/documentation.html).
