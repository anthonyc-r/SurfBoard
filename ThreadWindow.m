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
#import "View/PostView.h"
#import "View/ClickableImageView.h"
#import "Text/NSString+Links.h"
#import "SubmitPostWindow.h"

@interface ThreadWindow (private)
-(BOOL)focusPostWithNumber: (NSNumber*)postNumber;
-(NSArray*)displayedPostViews;
@end

@implementation ThreadWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"ThreadWindow init.");
	NSView *contentView = [self contentView];
	NSRect frame = [contentView bounds];
	NSLog(@"frame: %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	scrollView = [[NSScrollView alloc] initWithFrame: frame];
	[scrollView autorelease];
	[scrollView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[scrollView setLineScroll: 25];
	[scrollView setHasVerticalScroller: YES];
	[self setContentView: scrollView];
	selectedPostViews = [NSMutableArray new];
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
	networkSource = nil;
	[selectedPostViews removeAllObjects];
	highlightedPost = nil;
	[displayedThread release];
	displayedThread = detailedThread;
	[displayedThread retain];
	CGFloat scrollWidth = [[scrollView verticalScroller] frame].size.width;
	CGFloat width = [[self contentView] bounds].size.width - (20 + scrollWidth);
	NSArray *posts = [detailedThread getPosts];
	tableView = [[GSTable alloc] initWithNumberOfRows: [posts count] numberOfColumns: 1];
	[tableView autorelease];
	[tableView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	for (int i = 0; i < [posts count]; i++) {
		NSRect frame = NSMakeRect(
			0, 0, width, 200
		);
		Post *post = [posts objectAtIndex: i];
		NSView *view;
		PostView *postView = [[PostView alloc] 
			initWithFrame: frame];
		[postView autorelease];
		[postView configureForPost: post];
		frame.size.height = [postView getRequestedHeight];
		[postView setFrame: frame];
		[postView setDelegate: self];
		view = postView;
		[tableView putView: view atRow: [posts count] - (i + 1) 
			column: 0 withMargins: 10];
	}
	[scrollView setDocumentView: tableView];
	[tableView scrollPoint: NSMakePoint(0, [tableView bounds].size.height)];
}


-(void)didFailToFetchDetails: (NSError*)error {
	NSLog(@"Fetched detailed thread fail");
	[networkSource release];
	networkSource = nil;
}

-(void)refresh: (id)sender {
	NSLog(@"Thread Window Refresh");
	if (networkSource) {
		NSLog(@"Refresh in progress, ignoring");
		return;
	}
	if (displayedThread) {
		[self refreshForThread: displayedThread];
	}
}

-(void)postReply: (id)sender {
	NSLog(@"Selected posts: %@", selectedPostViews);
	NSEnumerator *selections = [selectedPostViews objectEnumerator];
	PostView *postView;
	while ((postView = [selections nextObject])) {
		[postView deselect];
	}
	// TODO: - Fill content to quote selected posts.
	NSLog(@"%@", submitPostWindow);
	[submitPostWindow configureForReplyingToThread: displayedThread];
	[submitPostWindow makeKeyAndOrderFront: self];
	
}

-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread {
	// Do nothing.
}

-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post {
	NSLog(@"Did tap image on post %@", post);
	[imageWindow makeKeyAndOrderFront: self];
	[imageWindow loadImageForPost: post];
}

-(void)postView: (PostView*)postView didSetSelected: (BOOL)isSelected forPost: (Post*)post {
	if (isSelected && ![selectedPostViews containsObject: postView]) {
		[selectedPostViews addObject: postView];
	} else if (!isSelected) {
		[selectedPostViews removeObject: postView];
	}
}

-(BOOL)textView: (NSTextView*)textView clickedOnLink: (id)link atIndex: (NSUInteger)charIndex {
	NSLog(@"clicked link: %@", link);
	NSNumber *postNumber = [link linkPostNumber];
	return [self focusPostWithNumber: postNumber];
}

-(BOOL)focusPostWithNumber: (NSNumber*)postNumber {
	// TODO: - Consider indexing the views by post number at refresh.
	// TODO: - OR just use a propper log time search given they're ordered!!!
	NSLog(@"Focus post number %@", postNumber);
	NSArray *postViews = [self displayedPostViews];
	for (int i = 0; i < [postViews count]; i++) {
		PostView *view = [postViews objectAtIndex: i];
		Post *otherPost = [view displayedPost];
		if ([postNumber isEqualToNumber: [otherPost getNumber]]) {
			NSView *jailView = [view superview];
			NSPoint target = [jailView frame].origin;
			target.y -= [scrollView frame].size.height - [jailView frame].size.height;
			[tableView scrollPoint: target];
			[highlightedPost setHighlight: NO];
			[view setHighlight: YES];
			highlightedPost = view;
			return YES;
		}
	}
	
	return NO;
}

-(NSArray*)displayedPostViews {
	NSMutableArray *postViews = [NSMutableArray array];
	NSArray *subviews = [tableView subviews];
	for (int i = 0; i < [subviews count]; i++) {
		NSView *view = [[[subviews objectAtIndex: i] subviews]
			objectAtIndex: 0];
		if ([view isKindOfClass: [PostView class]]) {	
			[postViews addObject: view];
		}
	}
	return postViews;
}

@end
