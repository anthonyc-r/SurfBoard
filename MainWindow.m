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
#import "Net/PassNetworkSource.h"
#import "Net/CaptchaChallengeNetworkSource.h"
#import "MenuItemTag.h"
#import "Net/NSURL+Utils.h"


@implementation MainWindow

-(void)awakeFromNib {
	NSLog(@"MainWindow loaded. wtf");
	NSView *contentView = [self contentView];
	NSRect frame = [contentView bounds];
	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	scrollView = [[NSScrollView alloc] initWithFrame: frame];
	[scrollView autorelease];
	[scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[scrollView setHasVerticalScroller: YES];
	[scrollView setLineScroll: 25];
	[self setContentView: scrollView];
	[self refresh: self];
	[self becomeFirstResponder];
}

-(void)dealloc {
	[networkSource release];
	[super dealloc];
}

-(NSScrollView*)scrollView {
	return scrollView;
}

-(NSView*)tableView {
	return tableView;
}

-(void)setTableView: (NSView*)aTableView {
	tableView = aTableView;
}

-(void)close {
	[super close];
	[NSApp terminate: self];
}

-(void)refresh: (id)sender {
	if (networkSource) {
		NSLog(@"Refresh already in progress, ignoring");
		return;
	}
	

	NSLog(@"Main window refresh?");
	NSString *code = [self getDisplayedBoard];
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

-(void)didTapPreferences: (id)sender {
	[preferencesWindow makeKeyAndOrderFront: self];
}

-(void)onIndexFetched: (NSArray*)threads {
	NSLog(@"Called network source success with thread %@", threads);
	[networkSource release];
	networkSource = nil;
	selectedOP = nil;
	[displayedThreads release];
	displayedThreads = threads;
	[displayedThreads retain];
	[self clearPosts];
	[self appendThreads: displayedThreads];
	[tableView scrollPoint: NSMakePoint(0, 0)];
	NSLog(@"Finished displaying threads %lu", [networkSource retainCount]);
}

-(void)postThread: (id)sender {
	[submitPostWindow configureForNewThreadOnBoard: 
		[self getDisplayedBoard]];
	[submitPostWindow setDelegate: self];
	[submitPostWindow makeKeyAndOrderFront: self];
}

-(void)postReply: (id)sender {
	Post *post = [selectedOP displayedPost];
	[selectedOP deselect];
	selectedOP = nil;
	NSArray *postNumbers = [NSArray arrayWithObject: [post getNumber]];
	[submitPostWindow configureForReplyingToOP: post 
		quotingPostNumbers: postNumbers];
	[submitPostWindow setDelegate: self];
	[submitPostWindow makeKeyAndOrderFront: self];
}

-(BOOL)validateMenuItem: (NSMenuItem*)menuItem {
	switch ([menuItem tag]) {
	case MenuItemTagReply:
		return selectedOP != nil;
	default:
		return YES;
	}	
}

-(NSString*)getDisplayedBoard {
	NSString *code = displayedBoard;
	if (code == nil) {
		// TODO: - Make home board
		code = @"g";
	}
	return code;
}

-(void)onIndexFailure: (NSError*)error {
	[networkSource release];
	networkSource = nil;
	NSLog(@"Error fetching front page: %@", error);
}

-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread {
	NSLog(@"DidTapView on thread %@", thread);
	[threadWindow makeKeyAndOrderFront: self];
	[threadWindow refreshForThread: thread];
}

-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post {
	NSLog(@"Did tap image on post %@", post);
	NSURL *imageURL = [NSURL urlForFullPostImage: post];
	[mediaManager displayMediaAtURL: imageURL observer: postView];
}

-(void)postView: (PostView*)postView didSetSelected: (BOOL)isSelected forPost: (Post*)post {
	if (selectedOP != nil) {
		[selectedOP deselect];
		selectedOP = nil;
	}
	if (isSelected) {
		selectedOP = postView;
	}
}

-(BOOL)textView: (NSTextView*)textView clickedOnLink: (id)link atIndex: (NSUInteger)charIndex {
	NSLog(@"clicked link: %@", link);
	return YES;
}

// NOTE: - The SubmitPostWindow delegate methods return partially filled out
// objects for Thread and Post, enough for ThreadWindow to refresh with them.

-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didCreateNewThread: (Thread*)thread {
	NSLog(@"Did create new thread: %@", thread);
	[aSubmitPostWindow configureForReplyingToOP: [thread getOP]
		quotingPostNumbers: [NSArray array]];
	[aSubmitPostWindow setDelegate: threadWindow];
	[threadWindow makeKeyAndOrderFront: self];
	[threadWindow refreshForThread: thread];
}

-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didReplyToThread: (Thread*)thread withPost: (Post*)post {
	NSLog(@"Did reply with post: %@", post);
	[aSubmitPostWindow setDelegate: threadWindow];
	[threadWindow makeKeyAndOrderFront: self];
	[threadWindow setFocusOnRefresh: post];
	[threadWindow refreshForThread: thread];
}

@end
