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
#import "Net/ThreadDetailsNetworkSource.h"
#import "GNUstepGUI/GSTable.h"
#import "Data/Thread.h"
#import "ThreadWindow.h"
#import "ImagePostView.h"

@implementation ThreadWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"ThreadWindow init.");
	NSView *contentView = [self contentView];
	NSRect frame = [contentView bounds];
	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	scrollView = [[NSScrollView alloc] initWithFrame: frame];
	[scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[scrollView setHasVerticalScroller: YES];
	[self setContentView: scrollView];
}

-(void)refreshForThread: (Thread*)thread {
	networkSource = [[ThreadDetailsNetworkSource alloc] initWithThread: thread];
	[networkSource performOnSuccess: @selector(didFetchDetails:) target: self];
	[networkSource performOnFailure: @selector(didFailToFetchDetails:) target: self];
	[networkSource fetch];
}

-(void)didFetchDetails: (Thread*)detailedThread {
	NSLog(@"Fetched detailed thread");
	[networkSource release];

	NSArray *posts = [detailedThread getPosts];
	[tableView removeFromSuperview];
	//[tableView autorelease];
	tableView = [[GSTable alloc] initWithNumberOfRows: [posts count] numberOfColumns: 1];
	[tableView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	for (int i = 0; i < [posts count]; i++) {
		NSRect frame = NSMakeRect(
			0, 0, width, 200
		);
		ImagePostView *postView = [[ImagePostView alloc] initWithFrame: frame];
		[postView autorelease];
		[postView configureForPost: [posts objectAtIndex: i]];
		[tableView putView: postView atRow: [posts count] - (i + 1) 
			column: 0 withMargins: 10];
	}
	NSLog(@"content: %@", [scrollView contentView]);
	[scrollView setDocumentView: tableView];
	[tableView scrollPoint: NSMakePoint(0, [tableView bounds].size.height)];
}


-(void)didFailToFetchDetails: (NSError*)error {
	NSLog(@"Fetched detailed thread");
	[networkSource release];
}

@end
