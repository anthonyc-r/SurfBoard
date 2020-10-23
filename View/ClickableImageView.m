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
#import "ClickableImageView.h"

@implementation ClickableImageView

-(id)initWithAction: (SEL)anAction target: (id)aTarget {
	if ((self = [super init])) {
		action = anAction;
		target = aTarget;
	}
	return self;
}

-(void)mouseUp: (NSEvent*)event {
	[target performSelectorOnMainThread: action withObject: nil 
		waitUntilDone: NO];
}

-(void)mouseDown: (NSEvent*)event {
	// Lol mouseUp isn't triggered unless this is implemented (?)
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

@end
