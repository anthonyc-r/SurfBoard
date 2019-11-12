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

#import <AppKit/AppKit.h>
#import "ImagePostView.h"
#import "Net/ImageNetworkSource.h"
#import "Net/NSURL+Utils.h"
#import "GNUstepGUI/GSTable.h"
#import "ClickableImageView.h"

static const CGFloat TOTAL_VERTICAL_MARGIN = 20.0;
static const CGFloat NO_MAXIMUM = 1000.0;

@implementation ImagePostView


-initWithFrame: (NSRect)frame {
	if ((self = [super initWithFrame: frame])) {
		maximumPostHeight = NO_MAXIMUM;
		imageView = [[ClickableImageView alloc] initWithAction: @selector(didTapImage) target: self];
		upperTextView = [[NSTextView alloc] init];
		viewButton = [[NSButton alloc] init];
		headlineLabel = [[NSTextView alloc] init];
		[self addSubview: imageView];
		[self addSubview: upperTextView];
		[self addSubview: viewButton];
		[self addSubview: headlineLabel];
		[viewButton setTitle: @"View"];
		[viewButton setTarget: self];
		[viewButton setAction: @selector(didTapView)];
		[viewButton setHidden: YES];
		[upperTextView setDrawsBackground: NO];
		[upperTextView setVerticallyResizable: NO];
		[upperTextView setEditable: NO];
		[upperTextView setRichText: YES];
		[headlineLabel setDrawsBackground: NO];
		[headlineLabel setEditable: NO];
		[headlineLabel setRichText: YES];
		[self layoutSubviews];
	}
	return self;
}

-(void)dealloc {
	[super dealloc];
	[imageView release];
	[upperTextView release];
	[viewButton release];
	[headlineLabel release];
}

-(void)drawRect: (NSRect)rect {
	[[NSColor colorWithDeviceRed: 0.9 green: 0.9 blue: 0.9 alpha: 0.9] set];
	[[NSBezierPath bezierPathWithRoundedRect: [self bounds]
		xRadius: 5 yRadius: 5] fill];
}

-(void)setFrame: (NSRect)frameRect {
	[super setFrame: frameRect];
	[self layoutSubviews];
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
	if (imageUrl) {
		activeImageSource = [[ImageNetworkSource alloc] initWithURL: imageUrl];
		[activeImageSource performOnSuccess: @selector(onFetchedImage:) target: self];
		[activeImageSource fetch];
	}
}

-(void)setPostBody: (NSString*)postBody {
	[upperTextView setText: postBody];
	[self layoutSubviews];
}

-(void)setImage: (NSImage*)image {
	[imageView setImage: image];
}

-(CGFloat)getRequestedHeight {
	return [upperTextView frame].size.height + TOTAL_VERTICAL_MARGIN;
}

-(CGFloat)getMaximumPostHeight {
	return maximumPostHeight;
}

-(void)setMaximumPostHight: (CGFloat)height {
	maximumPostHeight = height;
}

-(void)scrollToBottom {
	[upperTextView scrollRangeToVisible: NSMakeRange(1, 1)];
}

-(void)layoutSubviews {
	NSRect rect = [self bounds];
	[headlineLabel setFrame: NSMakeRect(
		10, rect.size.height - 20,
		rect.size.width - 20, 10
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

-(void)onFetchedImage: (NSImage*)image {
	NSLog(@"Fetched image!!");
	[imageView setImage: image];
}

-(void)setDelegate: (id<ImagePostViewDelegate>)aDelegate {
	delegate = aDelegate;
}

-(void)didTapView {
	[delegate imagePostView: self didTapViewOnThread: displayedThread];
}

-(void)didTapImage {
	[delegate imagePostView: self didTapImageOnPost: displayedPost];
}

@end
