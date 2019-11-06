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

static const CGFloat TOTAL_VERTICAL_MARGIN = 20.0;
static const CGFloat NO_MAXIMUM = 1000.0;

@implementation ImagePostView


-initWithFrame: (NSRect)frame {
	if ((self = [super initWithFrame: frame])) {
		maximumPostHeight = NO_MAXIMUM;
		imageView = [[NSImageView alloc] init];
		upperTextView = [[NSTextView alloc] init];
		[self addSubview: imageView];
		[self addSubview: upperTextView];
		[upperTextView setDrawsBackground: YES];
		[upperTextView setVerticallyResizable: NO];
		[upperTextView setEditable: NO];
		[upperTextView setRichText: YES];
		[self layoutSubviews];
	}
	return self;
}

-(void)drawRect: (NSRect)rect {
	[[NSColor blueColor] set];
	[[NSBezierPath bezierPathWithRect: [self bounds]] fill];
}

-(void)setFrame: (NSRect)frameRect {
	[super setFrame: frameRect];
	[self layoutSubviews];
}

-(void)configureForPost: (Post*)post {
	[self setAttributedPostBody: [post getAttributedBody]];
	activeImageSource = [[ImageNetworkSource alloc] initWithURL: [NSURL urlForThumbnail: post]];
	[activeImageSource performOnSuccess: @selector(onFetchedImage:) target: self];
	NSLog(@"Performing on background thread...");
	[activeImageSource performSelectorInBackground: @selector(fetch) withObject: nil];
	NSLog(@"Test 2");
}

-(void)setAttributedPostBody: (NSAttributedString*)postBody {
	[upperTextView replaceCharactersInRange: NSMakeRange(0, 0) withAttributedString: postBody];
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
	[imageView setFrame: NSMakeRect(
		10, rect.size.height - 110, 
		100, 100
	)];
	[upperTextView setFrame: NSMakeRect(
		120, 10, 
		rect.size.width - 130,
		rect.size.height - 20
	)];
}

-(void)onFetchedImage: (NSImage*)image {
	NSLog(@"Fetched image!!");
	[imageView setImage: image];
}

@end
