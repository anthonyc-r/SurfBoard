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

@implementation TextPostView

-initWithFrame: (NSRect)frame {
	if ((self = [super initWithFrame: frame])) {
		textView = [[NSTextView alloc] init];
		[textView setDrawsBackground: YES];
		[textView setRichText: YES];
		[textView setEditable: NO];
		[self addSubview: textView];
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
	[textView replaceCharactersInRange: NSMakeRange(0, 0) withAttributedString: [post getAttributedBody]];
}

-(void) layoutSubviews {
	NSRect frame = [self frame];
	[textView setFrame: NSMakeRect(
		10, 10,
		frame.size.width - 20,
		frame.size.height - 20
	)];
}

@end
