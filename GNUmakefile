#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

OPTFLAGS="-g"

# Build a simple Objective-C program
VERSION = 0.1
PACKAGE_NAME = SurfBoard
APP_NAME = SurfBoard
SurfBoard_APPLICATION_ICON = SurfBoard.tiff

# The Objective-C files to compile
SurfBoard_OBJC_FILES = AppDelegate.m MainWindow.m View/PostView.m \
	View/NSView+NibLoadable.m Theme.m Data/Post.m Net/NSURL+Utils.m Data/Thread.m \
	View/ThreadSummaryView.m Net/FrontPageNetworkSource.m Text/NSAttributedString+HTML.m \
	Text/NSFont+AppFont.m Net/DataNetworkSource.m ThreadWindow.m Net/NetworkSource.m \
	Net/ThreadDetailsNetworkSource.m ImageWindow.m View/ClickableImageView.m \
	Text/NSAttributedString+AppAttributes.m View/ZoomingScrollView.m \
	View/DraggableImageView.m View/NonScrollableTextView.m Text/NSString+Links.m \
	OpenBoardPanel.m NSError+AppErrors.m Text/DateFormatter.m Net/PassNetworkSource.m \
	View/PassLoginView.m PreferencesWindow.m Data/Pair.m Net/PostNetworkSource.m \
	SubmitPostWindow.m AppUserDefaults.m PostListWindow.m View/FlippedView.m \
	MediaManager.m View/MediaPreferencesView.m Net/CaptchaChallengeNetworkSource.m \
	Data/CaptchaChallenge.m CaptchaPanel.m
		
SurfBoard_H_FILES = AppDelegate.h MainWindow.h View/PostView.h \
	View/NSView+NibLoadable.h Theme.h Data/Post.h Net/NSURL+Utils.h Data/Thread.h \
	View/ThreadSummaryView.h Net/FrontPageNetworkSource.h Text/NSAttributedString+HTML.h \
	Text/NSFont+AppFont.h Net/DataNetworkSource.h ThreadWindow.h Net/NetworkSource.h \
	Net/ThreadDetailsNetworkSource.h ImageWindow.h View/ClickableImageView.h \
	Text/NSAttributedString+AppAttributes.h View/ZoomingScrollView.h \
	View/DraggableImageView.h NonScrollableTextView.h Text/NSString+Links.h \
	OpenBoardPanel.h NSError+AppErrors.h Text/DateFormatter.h Net/PassNetworkSurce.h \
	View/PassLoginView.h PreferencesWindow.h Data/Pair.h Net/PostNetworkSource.h \
	SubmitPostWindow.h AppUserDefaults.h PostListWindow.h View/FlippedView.h \
	MediaManager.h View/MediaPreferencesView.h Net/CaptchaChallengeNetworkSource.h \
	Data/CaptchaChallenge.h CaptchaPanel.h

SurfBoard_RESOURCE_FILES = Resources/MainWindow.gorm SurfBoardInfo.plist Resources/SurfBoard.tiff \
	Resources/PassLoginView.gorm Resources/MediaPreferencesView.gorm


-include GNUmakefile.preamble

# Include in the rules for making GNUstep command-line programs
include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/application.make

ADDITIONAL_FLAGS += -std=gnu99
-include GNUmakefile.postamble
