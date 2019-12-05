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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@implementation NSView(NibLoadable)

+(id)loadFromNibNamed: (NSString*)nibName {
	NSNib *nib = [[NSNib alloc] initWithNibNamed: nibName bundle: [NSBundle mainBundle]];
	if (!nib) {
		NSLog(@"Error loading nib named %@", nibName);
		return nil;
	} else {
		NSLog(@"Loaded nib object");
	}
	NSObject *tempOwner = [NSObject new];
	[tempOwner autorelease];
	NSArray *topLevelObjects;
	[nib instantiateNibWithOwner: tempOwner topLevelObjects: &topLevelObjects];
	if ([topLevelObjects count] < 1) {
		NSLog(@"No objects in nib.");
		return nil;
	}
	NSLog(@"Getting window from nib");
	NSWindow *window = [topLevelObjects objectAtIndex: 0];
	NSLog(@"Found window: %@", window);
	NSArray *subviews = [[window contentView] subviews];
	NSView *view = [subviews firstObject];
	[view retain];
	[window release];
	if (!view) {
		NSLog(@"Expected the Nib to contain a window top level object, with the target view as it's first subview.");
	} else {
		NSLog(@"Loaded nib named %@: %@", nibName, view);
	}
	return view;
}

@end
