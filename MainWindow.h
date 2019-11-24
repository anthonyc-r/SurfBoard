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
#import "Net/FrontPageNetworkSource.h"
#import "GNUstepGUI/GSTable.h"
#import "View/PostView.h"
#import "ThreadWindow.h"
#import "ImageWindow.h"
#import "OpenBoardPanel.h"

@interface MainWindow : NSWindow<PostViewDelegate>
{
	NSScrollView *scrollView;
	GSTable *tableView;
  	FrontPageNetworkSource *networkSource;
	ThreadWindow *threadWindow;
	ImageWindow *imageWindow;
	OpenBoardPanel *openBoardPanel;
	NSString *displayedBoard;
	NSArray *displayedThreads;
}
-(void)refresh: (id)sender;
-(void)open: (id)sender;
-(void)postThread: (id)sender;
@end
