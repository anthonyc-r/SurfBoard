/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <math.h>

#import <AppKit/AppKit.h>
#import "PostView.h"
#import "Net/DataNetworkSource.h"
#import "Net/NSURL+Utils.h"
#import "GNUstepGUI/GSTable.h"
#import "ClickableImageView.h"
#import "NonScrollableTextView.h"
#import "Theme.h"

static const CGFloat TEXT_VERTICAL_MARGIN = 60.0;
static const CGFloat IMAGE_VERTICAL_MARGIN = 90.0;
static const CGFloat IMAGE_MINIMUM_HEIGHT = 170.0;
static const CGFloat TEXT_MINIMUM_HEIGHT = 75.0;
static const CGFloat DEFAULT_MAXIMUM = 300.0;


@interface PostView (private)
-(void)layoutSubviews;
-(void)layoutForTextPost;
-(void)layoutForImagePost;
@end

@implementation PostView

-initWithFrame: (NSRect)frame {
	if ((self = [super initWithFrame: frame])) {
		maximumPostHeight = DEFAULT_MAXIMUM;
		imageView = [[ClickableImageView alloc] initWithAction: @selector(didTapImage) target: self];
		[imageView autorelease];
		upperTextView = [[NonScrollableTextView alloc] init];
		[upperTextView autorelease];
		viewButton = [[NSButton alloc] init];
		[viewButton autorelease];
		headlineLabel = [[NonScrollableTextView alloc] init];
		[headlineLabel autorelease];
		selectPostButton = [[NSButton alloc] init];
		[selectPostButton autorelease];
		backgroundColor = [Theme postBackgroundColor];
		[backgroundColor retain];
		[self addSubview: imageView];
		[self addSubview: upperTextView];
		[self addSubview: viewButton];
		[self addSubview: headlineLabel];
		[self addSubview: selectPostButton];
		[viewButton setTitle: @"View"];
		[viewButton setTarget: self];
		[viewButton setAction: @selector(didTapView)];
		[viewButton setHidden: YES];
		[upperTextView setDrawsBackground: NO];
		[upperTextView setVerticallyResizable: NO];
		[upperTextView setEditable: NO];
		[upperTextView setRichText: YES];
		[upperTextView setSelectable: YES];
		[headlineLabel setDrawsBackground: NO];
		[headlineLabel setEditable: NO];
		[headlineLabel setRichText: YES];
		[selectPostButton setButtonType: NSSwitchButton];
		[selectPostButton setTitle: @""];
		[selectPostButton setTarget: self];
		[selectPostButton setAction: @selector(didChangeSelection:)];
		[self layoutSubviews];
	}
	return self;
}

-(void)dealloc {
	[backgroundColor release];
	[activeImageSource cancel];
	[activeImageSource release];
	[super dealloc];
}

-(void)setFrame: (NSRect)frame {
	[super setFrame: frame];
	[self layoutSubviews];
}

-(void)drawRect: (NSRect)rect {
	[backgroundColor set];
	CGFloat cornerRadius = [Theme postCornerRadius];
	[[NSBezierPath bezierPathWithRoundedRect: [self bounds]
		xRadius: cornerRadius yRadius: cornerRadius] fill];
}

-(void)configureForThread: (Thread*)thread {
	displayedThread = thread;
	displayedPost = [thread getOP];
	[viewButton setHidden: NO];
	[self configureForPost: [thread getOP]];
}

-(void)configureForPost: (Post*)post {
	displayedPost = post;
	[headlineLabel replaceCharactersInRange: NSMakeRange(0, 0)
		withAttributedString: [post getAttributedHeadline]];
	[upperTextView replaceCharactersInRange: NSMakeRange(0, 0) 
		withAttributedString: [post getAttributedBody]];
	NSURL *imageUrl = [NSURL urlForThumbnail: post];
	if ([post hasImage] && imageUrl) {
		[imageView setHidden: NO];
		activeImageSource = [[DataNetworkSource alloc] initWithURL: imageUrl];
		[activeImageSource performOnSuccess: @selector(onFetchedImage:) target: self];
		[activeImageSource performOnFailure: @selector(onImageFail:) target: self];
		[activeImageSource fetch];
	} else {
		[imageView setHidden: YES];
	}	
}

-(void)mediaBeganLoading {
	NSLog(@"Media began loading");
	[imageView setAlphaValue: 0.5];
	/*
	NSRect frame = [imageView frame];
	frame.size.height = 10;
	frame.origin.y -= 10;
	NSProgressIndicator *indicator = [[NSProgressIndicator alloc]
		initWithFrame: frame];
	[indicator setAlphaValue: 0.5];
	[self addSubview: indicator];
	[indicator startAnimation: self];
	*/
}

-(void)mediaFinishedLoading {
	NSLog(@"Media finished loading");
	[imageView setAlphaValue: 1.0];
}

-(void)setPostBody: (NSString*)postBody {
	[upperTextView setText: postBody];
	[self layoutSubviews];
}

-(void)setImage: (NSImage*)image {
	[imageView setImage: image];
}

-(CGFloat)getRequestedHeight {
	CGFloat minimumHeight = [displayedPost hasImage] ?
		IMAGE_MINIMUM_HEIGHT : TEXT_MINIMUM_HEIGHT;
	CGFloat verticalMargin = [displayedPost hasImage] ?
		IMAGE_VERTICAL_MARGIN : TEXT_VERTICAL_MARGIN;
	NSAttributedString *displayedBody = [displayedPost getAttributedBody];
	CGFloat width = [upperTextView frame].size.width;
	NSRect rect = [displayedBody 
		boundingRectWithSize: NSMakeSize(width, maximumPostHeight) 
		options: NSStringDrawingUsesLineFragmentOrigin];
	return fmax(rect.size.height + verticalMargin, minimumHeight);
	
}

-(void)scrollToBottom {
	[upperTextView scrollRangeToVisible: NSMakeRange(1, 1)];
}

-(Post*)displayedPost {
	return displayedPost;
}

-(void)layoutSubviews {
	if ([displayedPost hasImage]) {
		[self layoutForImagePost];
	} else {
		[self layoutForTextPost];
	}	
}

-(void)layoutForImagePost {
	NSRect rect = [self bounds];
	[selectPostButton setFrame: NSMakeRect(
		7, rect.size.height - 22,
		20, 20
	)];
	[headlineLabel setFrame: NSMakeRect(
		25, rect.size.height - 20,
		rect.size.width - 40, 10
	)];
	[imageView setFrame: NSMakeRect(
		10, rect.size.height - 130, 
		100, 100
	)];
	[upperTextView setFrame: NSMakeRect(
		120, 40, 
		rect.size.width - 130,
		rect.size.height - 70
	)];
	[viewButton setFrame: NSMakeRect(
		rect.size.width - 60, 10,
		50, 20
	)];
}

-(void)layoutForTextPost {
	NSRect rect = [self bounds];
	[selectPostButton setFrame: NSMakeRect(
		7, rect.size.height - 22,
		20, 20
	)];
	[headlineLabel setFrame: NSMakeRect(
		25, rect.size.height - 20,
		rect.size.width - 40, 10
	)];
	[upperTextView setFrame: NSMakeRect(
		10, 10, 
		rect.size.width - 20,
		rect.size.height - 40
	)];
}

-(void)onFetchedImage: (NSData*)data {
	NSImage *image = [[[NSImage alloc] initWithData: data] autorelease];
	[activeImageSource release];
	activeImageSource = nil;
	[imageView setImage: image];
}

-(void)onImageFail: (NSError*)error {
	[activeImageSource release];
	activeImageSource = nil;
}

-(void)setDelegate: (id<PostViewDelegate>)aDelegate {
	delegate = aDelegate;
	[upperTextView setDelegate: aDelegate];
}

-(void)setHighlight: (BOOL)highlight {
	[backgroundColor release];
	if (highlight) {
		backgroundColor = [Theme postBackgroundHighlightColor];
	} else {
		backgroundColor = [Theme postBackgroundColor];
	}
	[backgroundColor retain];
	[self setNeedsDisplay: YES];
}

-(void)didTapView {
	[delegate postView: self didTapViewOnThread: displayedThread];
}

-(void)didTapImage {
	[delegate postView: self didTapImageOnPost: displayedPost];
}

-(void)didChangeSelection: (NSButton*)sender {
	if ([sender state] == NSOnState) {
		[delegate postView: self didSetSelected: YES 
			forPost: displayedPost];
	} else {
		[delegate postView: self didSetSelected: NO
			forPost: displayedPost];
	}
}

-(void)deselect {
	[selectPostButton setState: NSOffState];
}

@end

