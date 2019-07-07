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

+(id)loadFromNibNamed: (NSString*)nibName owner: (id)owner {
	NSNib *nib = [[NSNib alloc] initWithNibNamed: nibName bundle: [NSBundle mainBundle]];
	if (!nib) {
		NSLog(@"Error loading nib named %@", nibName);
		return nil;
	}
	NSArray *topLevelObjects;
	[nib instantiateNibWithOwner: owner topLevelObjects: &topLevelObjects];
	if ([topLevelObjects count] < 1) {
		NSLog(@"No objects in nib.");
		return nil;
	}
	NSView *view = [topLevelObjects objectAtIndex: 0];
	if (!view) {
		NSLog(@"Object at index 0 was not a NSView or subclass of this.");
	} else {
		NSLog(@"Loaded nib named %@", nibName);
	}
	[view autorelease];
	//[topLevelObjects release];
	//[nib release];
	return view;
}

@end
