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
#import <Foundation/Foundation.h>
#import "View/PostView.h"
#import "Data/Post.h"
#import "PostListWindow.h"


static const CGFloat POST_MARGIN_H = 10;
static const CGFloat POST_MARGIN_V = 20;

@implementation PostListWindow

-(NSArray*)displayedPostViews {
	NSMutableArray *postViews = [NSMutableArray array];
	NSArray *subviews = [[self tableView] subviews];
	for (int i = 0; i < [subviews count]; i++) {
		NSView *view = [subviews objectAtIndex: i];
		if ([view isKindOfClass: [PostView class]]) {
			[postViews addObject: view];
		}
	}
	return postViews;
}

-(void)clearPosts {
	CGFloat scrollWidth = [[[self scrollView] verticalScroller] frame].size.width;
	CGFloat width = [[self scrollView] frame].size.width - scrollWidth;
	NSView *tableView = [[NSView alloc] initWithFrame: NSMakeRect(
		0, 0,
		width, 0
	)];
	[tableView autorelease];
	[tableView setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
	[self setTableView: tableView];
	[[self scrollView] setDocumentView: tableView];
}

-(void)appendPosts: (NSArray*)posts {
	CGFloat width = [[self tableView] bounds].size.width - (2 * POST_MARGIN_H);
	NSRect currentFrame = [[self tableView] frame];
	CGFloat heightCursor = currentFrame.size.height + POST_MARGIN_V;
	
	NSEnumerator *enumerator = [posts objectEnumerator];
	Post *post;
	NSMutableArray *appendedPostViews = [NSMutableArray array];
	while ((post = [enumerator nextObject])) {
		NSRect frame = NSMakeRect(
			POST_MARGIN_H, heightCursor, width, 200
		);
		PostView *postView = [[PostView alloc] 
			initWithFrame: frame];
		[postView autorelease];
		[postView configureForPost: post];
		frame.size.height = [postView getRequestedHeight];
		[postView setFrame: frame];
		[postView setDelegate: self];
		[[self tableView] addSubview: postView];
		[appendedPostViews addObject: postView];	
		heightCursor += frame.size.height + POST_MARGIN_V;
	}
	currentFrame.size.height = heightCursor;
	[[self tableView] setFrame: currentFrame];
	// Reshuffle the origins to account for coordinate space
	enumerator = [appendedPostViews objectEnumerator];
	PostView *postView;
	heightCursor -= POST_MARGIN_V;
	while ((postView = [enumerator nextObject])) {
		NSRect frame = [postView frame];
		frame.origin.y = heightCursor - frame.size.height;
		[postView setFrame: frame];
		heightCursor -= frame.size.height + POST_MARGIN_V;
	}
}

-(NSScrollView*)scrollView {
	return nil;
}

-(NSView*)tableView {
	return nil;
}

-(void)setTableView: (NSView*)aTableView {

}

-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread {

}

-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post {

}

-(void)postView: (PostView*)postView didSetSelected: (BOOL)isSelected forPost: (Post*)post {

}

@end
