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
	NSRect frame = [contentView frame];
	tableView = [[GSTable alloc] initWithFrame: NSMakeRect(0, 0, frame.size.width, frame.size.height)];
	[contentView addSubview: tableView];
	
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
	[tableView addColumn];
	for (int i = 0; i < [threads count]; i++) {
		Post *op = [[[threads objectAtIndex: i] getPosts] firstObject];
		NSRect frame = NSMakeRect(
			0, 0, 200, 100
		);
		ImagePostView *postView = [[ImagePostView alloc] initWithFrame: frame];
		//[postView configureForPost: op];
		[tableView addRow];
		[tableView putView: postView atRow: i column: 0];
		
	}
}

@end
