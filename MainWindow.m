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
	//postView = [ImagePostView loadFromNibNamed: @"ImagePostView" owner: NSApp];
	postView = [[ImagePostView alloc] initWithFrame: NSMakeRect(50, 200, 600, 200)];
	//[postView setFrame: NSMakeRect(50, 200, 200, 200)];
	[[self contentView] addSubview: postView];
	
	networkSource = [[FrontPageNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(networkSourceTest:) target: self];
	NSLog(@"Fetching network source.");
	[NSThread detachNewThreadSelector: @selector(fetch) toTarget: networkSource withObject: nil];
}

-(void)testFunc: (Post*)sender {
	NSLog(@"Called into test func with thread %@ with body: %@", sender, [sender getBody]);

}

-(void)networkSourceTest: (NSArray*)threads {
	NSLog(@"Called network source success with thread %@", threads);
	NSLog(@"First object: %@", [threads firstObject]);
	NSArray *posts = [[threads firstObject] getPosts];
	id post = [posts firstObject];
	if (post) {
		NSLog(@"Post was not null");
		NSLog(@"post %@", post);
		[postView configureForPost: post];
	} else {
		NSLog(@"Post was null!?");
	}
}

@end
