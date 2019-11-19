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
#import "View/PostView.h"
#import "View/NSView+NibLoadable.h"
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
	NSString *code = displayedBoard;
	if (code == nil) {
		// TODO: - Make home board
		code = @"g";
	}
	networkSource = [[FrontPageNetworkSource alloc] initWithCode: code];
	[networkSource performOnSuccess: @selector(onIndexFetched:) target: self];
	[networkSource performOnFailure: @selector(onIndexFailure:) target: self];
	[networkSource fetch];
}

-(void)open: (id)sender {
	NSLog(@"Open...");
	[NSApp runModalForWindow: openBoardPanel];
	NSString *board = [openBoardPanel pickedValue];
	NSLog(@"Opening board... %@", board);
	if (board == nil || [board length] < 1) {
		return;
	}
	[displayedBoard release];
	displayedBoard = board;
	[displayedBoard retain];
	[self refresh: nil];
}

-(void)onIndexFetched: (NSArray*)threads {
	[networkSource release];
	NSLog(@"Called network source success with thread %@", threads);
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
		PostView *postView = [[PostView alloc] initWithFrame: frame];
		[postView configureForThread: [threads objectAtIndex: i]];
		frame.size.height = [postView getRequestedHeight];
		[postView setFrame: frame];
		[postView setDelegate: self];
		[tableView putView: postView atRow: [threads count] - (i + 1)
			column: 0 withMargins: 10];
	}
	[scrollView setDocumentView: tableView];
	[tableView scrollPoint: NSMakePoint(0, [tableView bounds].size.height)];
}

-(void)onIndexFailure: (NSError*)error {
	[networkSource release];
	NSLog(@"Error fetching front page: %@", error);
}

-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread {
	NSLog(@"DidTapView on thread %@", thread);
	[threadWindow makeKeyAndOrderFront: self];
	[threadWindow refreshForThread: thread];
}

-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post {
	NSLog(@"Did tap image on post %@", post);
	[imageWindow makeKeyAndOrderFront: self];
	[imageWindow loadImageForPost: post];
}

-(BOOL)textView: (NSTextView*)textView clickedOnLink: (id)link atIndex: (NSUInteger)charIndex {
	NSLog(@"clicked link: %@", link);
	return YES;
}

@end
