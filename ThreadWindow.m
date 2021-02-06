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
#import "MediaManager.h"
#import "Net/NSURL+Utils.h"


@interface ThreadWindow (private)
-(BOOL)focusPostWithNumber: (NSNumber*)postNumber;
@end

@implementation ThreadWindow

-(void)awakeFromNib {
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

-(NSScrollView*)scrollView {
	return scrollView;
}

-(NSView*)tableView {
	return tableView;
}

-(void)setTableView: (NSView*)aTableView {
	tableView = aTableView;
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
	
	NSNumber *newThreadOP = [[detailedThread getOP] getNumber];
	NSNumber *oldThreadOP = [[displayedThread getOP] getNumber];
	BOOL didThreadChange = ![oldThreadOP isEqualToNumber: newThreadOP];
	
	if (didThreadChange) {
		[selectedPostViews removeAllObjects];
		highlightedPost = nil;
		[displayedThread release];
		displayedThread = detailedThread;
		[displayedThread retain];
		[self clearPosts];
		[self appendPosts: [displayedThread getPosts]];
		if (focusOnRefresh == nil) {
			[tableView scrollPoint: NSMakePoint(0, 0)];
		}
	} else {
		NSArray *new = [detailedThread getPosts];
		NSArray *old = [displayedThread getPosts];
		NSArray *additional = [self getNewPostsFromUpdatedPosts: new
			oldPosts: old];
		[displayedThread setPosts: [old arrayByAddingObjectsFromArray:
			additional]];
		[self appendPosts: additional];
	}

	
	[self focusPostWithNumber: [focusOnRefresh
		getNumber]];
	[self setFocusOnRefresh: nil];
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
	NSMutableArray *postNumbers = [[NSMutableArray alloc] init];
	[postNumbers autorelease];
	while ((postView = [selections nextObject])) {
		[postView deselect];
		[postNumbers addObject: [[postView displayedPost] getNumber]];
	}
	[submitPostWindow configureForReplyingToOP: [displayedThread getOP]
		quotingPostNumbers: postNumbers];
	[submitPostWindow setDelegate: self];
	[submitPostWindow makeKeyAndOrderFront: self];
	
}

-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread {
	// Do nothing.
}

-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post {
	NSLog(@"Did tap image on post %@", post);
	[mediaManager displayMediaAtURL: [NSURL urlForFullPostImage: post]
		observer: postView];
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

-(void)setFocusOnRefresh: (Post*)post {
	[focusOnRefresh release];
	focusOnRefresh = post;
	[focusOnRefresh retain];
}

-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didCreateNewThread: (Thread*)thread {
	// Shouldn't be called.
}

-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didReplyToThread: (Thread*)thread withPost: (Post*)post {
	NSLog(@"Did reply to thread.");
	[self setFocusOnRefresh: post];
	[self refresh: aSubmitPostWindow];
}


-(BOOL)focusPostWithNumber: (NSNumber*)postNumber {
	// TODO: - Consider indexing the views by post number at refresh.
	// TODO: - OR just use a propper log time search given they're ordered!!!
	if (postNumber == nil) {
		return NO;
	}
	NSLog(@"Focus post number %@", postNumber);
	NSArray *postViews = [self displayedPostViews];
	for (int i = 0; i < [postViews count]; i++) {
		PostView *view = [postViews objectAtIndex: i];
		Post *otherPost = [view displayedPost];
		NSLog(@"Compare num %@, to %@", postNumber, [otherPost getNumber]);
		if ([postNumber isEqualToNumber: [otherPost getNumber]]) {
			NSPoint target = [view frame].origin;
			NSLog(@"Scrollpoint: %f, %f", target.x, target.y);
			[tableView scrollPoint: target];
			[highlightedPost setHighlight: NO];
			[view setHighlight: YES];
			highlightedPost = view;
			return YES;
		}
	}
	
	return NO;
}

-(NSArray*)getNewPostsFromUpdatedPosts: (NSArray*)updatedPosts oldPosts: (NSArray*)oldPosts {
	// Manually search through them rather than just using the lengths
	// since posts may have been deleted.
	NSDate *latestPostDate = [[oldPosts lastObject] getPostDate];
	int maxIdx = [updatedPosts count] - 1;
	int splitIdx = -1;
	for (int i = maxIdx; i >= 0; i--) {
		Post *post = [updatedPosts objectAtIndex: i];
		NSDate *postDate = [post getPostDate];
		splitIdx = i;
		BOOL isPostNewer = [postDate compare: latestPostDate] 
			== NSOrderedDescending;
		if (!isPostNewer) { 	
			break;
		}
	}
	NSLog(@"split index found as: %d out of %d", splitIdx, maxIdx);
	if (splitIdx >= 0 && splitIdx < maxIdx) {
		NSRange range = NSMakeRange(
			splitIdx + 1,
			maxIdx - splitIdx
		);
		NSLog(@"returning updatedPosts from array");
		return [updatedPosts subarrayWithRange: range];
	} else {
		NSLog(@"No updated posts");
		return [NSArray array];
	}
}

@end
