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
#import <Foundation/Foundation.h>
#import "ZoomingScrollView.h"

static const CGFloat ZOOM_SPEED = 30;

@implementation ZoomingScrollView

-(void)scrollWheel: (NSEvent*)event {
	NSRect frame = [[self documentView] frame];
	CGFloat delta = [event deltaY] * ZOOM_SPEED;
	NSSize size = [self bounds].size;

	frame.size.width += delta;
	frame.size.height += delta;
	frame.origin.x -= 0.5 * delta;
	frame.origin.y -= 0.5 * delta;
	
	if (delta >= 0 || frame.size.width >= size.width) {
		[[self documentView] setFrame: frame];
		[self setNeedsDisplay: YES];
	}
}

-(void)mouseDragged: (NSEvent*)event {
	if (!NSMouseInRect([event locationInWindow], [self bounds], NO)) {
		return;
	}
	NSRect newFrame = [[self documentView] frame];

	newFrame.origin.x += [event deltaX];
	newFrame.origin.y += [event deltaY];
	
	[[self documentView] setFrame: newFrame];
	[self setNeedsDisplay: YES];
}

-(void)resizeSubviewsWithOldSize: (NSSize)oldSize {
	[super resizeSubviewsWithOldSize: oldSize];
	[[self documentView] setFrame: [self bounds]];
}

@end
