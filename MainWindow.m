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
	ImagePostView *imagePostView = [ImagePostView loadFromNibNamed: @"ImagePostView" owner: NSApp];
	[imagePostView setPostBody: @"Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post b"];
	[[self contentView] addSubview: imagePostView];
	Post *p = [[Post alloc] init];
	[p setBody: @"Test!?!"];
	[p performWithThumbnail: @selector(testFunc:sender:) target: self];
	
	FrontPageNetworkSource *networkSource = [[FrontPageNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(networkSourceTest:) target: self];
	NSLog(@"Fetching network source.");
	[networkSource fetch];
}

-(void)testFunc: (Post*)sender {
	NSLog(@"Called into test func with thread %@ with body: %@", sender, [sender getBody]);

}

-(void)networkSourceTest: (id)thread {
	NSLog(@"Called network source success with thread %@", thread);
}

@end
