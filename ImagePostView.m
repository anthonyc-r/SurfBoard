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

#include <AppKit/AppKit.h>
#include "ImagePostView.h"

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
	[upperTextView setDrawsBackground: NO];
	[upperTextView setVerticallyResizable: YES];
	[upperTextView setEditable: NO];
	CGFloat viewHeight = [self frame].size.height;
	[upperTextView setMaxSize: NSMakeSize(viewHeight, 1000)];
	[upperTextView setMinSize: NSMakeSize(viewHeight, 0)];
}


-(void)setFrame: (NSRect)frameRect {
	[super setFrame: frameRect];
	NSLog(@"Frame set, changing textview constraints");
	[upperTextView setMaxSize: NSMakeSize(frameRect.size.height, maximumPostHeight)];
	[upperTextView setMinSize: NSMakeSize(frameRect.size.height, 0)];
}

-(void)setPostBody: (NSString*)postBody {
	[upperTextView setString: postBody];
	NSRect prevFrame = [upperTextView frame];
	[upperTextView sizeToFit];
	NSRect newFrame = [upperTextView frame];
	CGFloat heightDiff = prevFrame.size.height - newFrame.size.height;
	newFrame.origin.y += heightDiff;
	NSLog(@"newFrame x: %f y: %f width: %f height: %f", newFrame.origin.x, 
		newFrame.origin.y, newFrame.size.width, newFrame.size.height);
	[upperTextView setFrame: newFrame];
	
	NSLog(@"text view height: %f", newFrame.size.height);
	
}

-(void)setImage: (NSImage*)image {
	[imageView setImage: image];
}

-(CGFloat)getRequestedSize {
	return [upperTextView frame].size.height + TOTAL_VERTICAL_MARGIN;
}

-(CGFloat)getMaximumPostHeight {
	return maximumPostHeight;
}
-(void)setMaximumPostHight: (CGFloat)height {
	maximumPostHeight = height;
}

@end
