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
#import "GNUstepGUI/GSTable.h"
#import "Data/Thread.h"
#import "Net/ThreadDetailsNetworkSource.h"
#import "ImageWindow.h"
#import "View/PostView.h"
#import "SubmitPostWindow.h"

@interface ThreadWindow: NSWindow<PostViewDelegate, SubmitPostWindowDelegate>
{
	NSScrollView *scrollView;
	GSTable *tableView;
  	ThreadDetailsNetworkSource *networkSource;
	Thread *displayedThread;
	ImageWindow *imageWindow;
	PostView *highlightedPost;
	SubmitPostWindow *submitPostWindow;
	NSMutableArray *selectedPostViews;
	Post *focusOnRefresh;
}

-(void)refreshForThread: (Thread*)thread;
-(void)didFetchDetails: (Thread*)detailedThread;
-(void)didFailToFetchDetails: (NSError*)error;
-(void)refresh: (id)sender;
-(void)postReply: (id)sender;
-(void)setFocusOnRefresh: (Post*)post;
-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didCreateNewThread: (Thread*)thread;
-(void)submitPostWindow: (SubmitPostWindow*)aSubmitPostWindow didReplyToThread: (Thread*)thread withPost: (Post*)post;
@end
