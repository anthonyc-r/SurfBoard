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
#include "TextPostView.h"

static const CGFloat NO_MAXIMUM = 1000.0;

@implementation TextPostView

-initWithFrame: (NSRect)frame {
	if ((self = [super initWithFrame: frame])) {
		maximumPostHeight = NO_MAXIMUM;
		upperTextView = [[NSTextView alloc] init];
		headlineLabel = [[NSTextView alloc] init];
		[self addSubview: upperTextView];
		[self addSubview: headlineLabel];
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
	[upperTextView release];
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

-(void)configureForPost: (Post*)post {
	displayedPost = post;
	[headlineLabel replaceCharactersInRange: NSMakeRange(0, 0) withAttributedString: [post getAttributedHeadline]];
	[upperTextView replaceCharactersInRange: NSMakeRange(0, 0) 
		withAttributedString: [post getAttributedBody]];
}

-(void)layoutSubviews {
	NSRect rect = [self bounds];
	[headlineLabel setFrame: NSMakeRect(
		10, rect.size.height - 20,
		rect.size.width - 20, 10
	)];
	[upperTextView setFrame: NSMakeRect(
		10, 10, 
		rect.size.width - 20,
		rect.size.height - 40
	)];
}

@end
