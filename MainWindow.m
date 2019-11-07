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
#include "MainWindow.h"
#include "ImagePostView.h"
#include "NSView+NibLoadable.h"
#include "Data/Thread.h"
#include "Net/FrontPageNetworkSource.h"

@implementation MainWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"MainWindow loaded.");
	NSView *contentView = [self contentView];
	NSRect frame = [contentView bounds];
	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	tableView = [GSTable alloc];
	scrollView = [[NSScrollView alloc] initWithFrame: frame];
	[scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[contentView addSubview: scrollView];
	
	networkSource = [[FrontPageNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(networkSourceTest:) target: self];
	NSLog(@"Fetching network source.");
	[networkSource performSelectorInBackground: @selector(fetch) withObject: nil];
}

-(void)testFunc: (Post*)sender {
	NSLog(@"Called into test func with thread %@ with body: %@", sender, [sender getBody]);

}

-(void)networkSourceTest: (NSArray*)threads {
	NSLog(@"Called network source success with thread %@", threads);
	NSLog(@"First object: %@", [threads firstObject]);
	CGFloat width = [[self contentView] bounds].size.width;
	[tableView removeFromSuperview];
	[tableView initWithNumberOfRows: [threads count] numberOfColumns: 1];
	[tableView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	for (int i = 0; i < [threads count]; i++) {
		Post *op = [[[threads objectAtIndex: i] getPosts] firstObject];
		NSRect frame = NSMakeRect(
			0, 0, width, 200
		);
		ImagePostView *postView = [[ImagePostView alloc] initWithFrame: frame];
		[postView configureForPost: op];
		[tableView putView: postView atRow: i column: 0];
		[tableView setYResizingEnabled: YES forRow: i];
		[tableView setXResizingEnabled: YES forColumn: i];
	}
	NSLog(@"content: %@", [scrollView contentView]);
	[scrollView setDocumentView: tableView];
}

@end
