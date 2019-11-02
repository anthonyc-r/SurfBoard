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

static const CGFloat TOTAL_VERTICAL_MARGIN = 20.0;
static const CGFloat NO_MAXIMUM = 1000.0;

@implementation ImagePostView

-init {
	if (self = [super init]) {
		maximumPostHeight = NO_MAXIMUM;
	}
	return self;
}

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"ImagePostView awoke from nib.");
	maximumPostHeight = NO_MAXIMUM;
	[upperTextView setDrawsBackground: YES];
	[upperTextView setVerticallyResizable: YES];
	[upperTextView setEditable: NO];
	[upperTextView setRichText: YES];
	CGFloat viewHeight = [self frame].size.height;
	[upperTextView setMaxSize: NSMakeSize(viewHeight, NO_MAXIMUM)];
	[upperTextView setMinSize: NSMakeSize(viewHeight, 0)];
}

-(void)setFrame: (NSRect)frameRect {
	[super setFrame: frameRect];
	NSLog(@"Frame set, changing textview constraints");
	[upperTextView setMaxSize: NSMakeSize(frameRect.size.width, maximumPostHeight)];
	[upperTextView setMinSize: NSMakeSize(frameRect.size.width, 0)];
	[self updateFrame];
}

-(void)configureForPost: (Post*)post {
	[self setAttributedPostBody: [post getAttributedBody]];
}

-(void)setAttributedPostBody: (NSAttributedString*)postBody {
	[upperTextView replaceCharactersInRange: NSMakeRange(0, 0) withAttributedString: postBody];
	[self updateFrame];
}

-(void)setPostBody: (NSString*)postBody {
	[upperTextView setText: postBody];
	[self updateFrame];
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

-(void)updateFrame {
	NSRect prevFrame = [upperTextView frame];
	[upperTextView sizeToFit];
	[self performSelector: @selector(scrollToBottom) onThread: [NSThread mainThread] withObject: nil waitUntilDone: NO];
	return;
	NSRect newFrame = [upperTextView frame];
	CGFloat heightDiff = prevFrame.size.height - newFrame.size.height;
	newFrame.origin.y += heightDiff;
	NSLog(@"newFrame x: %f y: %f width: %f height: %f", newFrame.origin.x, 
		newFrame.origin.y, newFrame.size.width, newFrame.size.height);
	[upperTextView setFrame: newFrame];
	NSLog(@"text view height: %f", newFrame.size.height);
	
}

-(void)scrollToBottom {
	[upperTextView scrollRangeToVisible: NSMakeRange(1, 1)];
}

@end
