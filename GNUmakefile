#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build a simple Objective-C program
VERSION = 0.1
PACKAGE_NAME = RedditPro
APP_NAME = RedditPro
Terminal_APPLICATION_ICON =

# The Objective-C files to compile
RedditPro_OBJC_FILES = AppDelegate.m MainWindow.m ImagePostView.m TextPostView.m \
	NSView+NibLoadable.m Theme.m Data/Post.m Net/NSURL+Utils.m Data/Thread.m \
	ThreadSummaryView.m Net/FrontPageNetworkSource.m Text/NSAttributedString+HTML.m \
	Text/NSFont+AppFont.m Net/ImageNetworkSource.m
	
RedditPro_H_FILES = AppDelegate.h MainWindow.h ImagePostView.h TextPostView.h \
	NSView+NibLoadable.h Theme.h Data/Post.h Net/NSURL+Utils.h Data/Thread.h \
	ThreadSummaryView.h Net/FrontPageNetworkSource.h Text/NSAttributedString+HTML.h \
	Text/NSFont+AppFont.h Net/ImageNetworkSource.m

RedditPro_RESOURCE_FILES = Resources/MainWindow.gorm Resources/ImagePostView.gorm Resources/TextPostView.gorm


-include GNUmakefile.preamble

# Include in the rules for making GNUstep command-line programs
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
