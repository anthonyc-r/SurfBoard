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

#import "AppDelegate.h"


@implementation AppDelegate 

- (void) applicationDidFinishLaunching: (NSNotification*)aNotification {
	NSLog(@"NSApp did finish launching..");
	[NSBundle loadNibNamed: @"MainWindow" owner: self];
}

@end

int main(int argc, char **argv) {	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSApplication *app = [NSApplication sharedApplication];
	AppDelegate *delegate = [AppDelegate new];
	[app setDelegate: delegate];
	[app run];
	[pool release];
	return 0;
}
