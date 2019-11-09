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
#import "MainWindow.h"
#import "ImagePostView.h"
#import "NSView+NibLoadable.h"
#import "Data/Thread.h"
#import "Data/Post.h"
#import "Net/FrontPageNetworkSource.h"

@implementation MainWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"MainWindow loaded.");
	NSView *contentView = [self contentView];
	NSRect frame = [contentView bounds];
	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	scrollView = [[NSScrollView alloc] initWithFrame: frame];
	[scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[scrollView setHasVerticalScroller: YES];
	[scrollView setLineScroll: 25];
	[self setContentView: scrollView];
	[self refresh: self];
	[self becomeFirstResponder];

}

-(void)dealloc {
	[super dealloc];
	[scrollView release];
	[tableView release];
	[networkSource release];
}

-(void)close {
	[super close];
	[NSApp terminate: self];
}

-(void)refresh: (id)sender {
	NSLog(@"Main window refresh?");
	networkSource = [[FrontPageNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(onIndexFetched:) target: self];
	[networkSource performOnFailure: @selector(onIndexFailure:) target: self];
	[networkSource fetch];
}

-(void)onIndexFetched: (NSArray*)threads {
	[networkSource release];
	NSLog(@"Called network source success with thread %@", threads);
	NSLog(@"First object: %@", [threads firstObject]);
	CGFloat scrollWidth = [[scrollView verticalScroller] frame].size.width;
	CGFloat width = [[self contentView] bounds].size.width - (20 + scrollWidth);
	[tableView removeFromSuperview];
	// TODO: - Release without crashing!?
	//[tableView release];
	tableView = [[GSTable alloc] initWithNumberOfRows: [threads count] numberOfColumns: 1];
	[tableView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];

	for (int i = [threads count] - 1; i >= 0; i--) {
		NSRect frame = NSMakeRect(
			0, 0, width, 200
		);
		ImagePostView *postView = [[ImagePostView alloc] initWithFrame: frame];
		[postView configureForThread: [threads objectAtIndex: i]];
		[postView setDelegate: self];
		[tableView putView: postView atRow: [threads count] - (i + 1)
			column: 0 withMargins: 10];
	}
	NSLog(@"content: %@", [scrollView contentView]);
	[scrollView setDocumentView: tableView];
	[tableView scrollPoint: NSMakePoint(0, [tableView bounds].size.height)];
}

-(void)onFirstPageFailure: (NSError*)error {
	[networkSource release];
	NSLog(@"Error fetching front page: %@", error);
}

-(void)imagePostView: (ImagePostView*)imagePostView didTapViewOnThread: (Thread*)thread {
	NSLog(@"DidTapView on thread %@", thread);
	[threadWindow makeKeyAndOrderFront: self];
	[threadWindow refreshForThread: thread];
}

@end
