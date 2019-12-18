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
#import "PreferencesWindow.h"
#import "SubmitPostWindow.h"

@interface MainWindow : NSWindow<PostViewDelegate, SubmitPostWindowDelegate>
{
	NSScrollView *scrollView;
	GSTable *tableView;
  	FrontPageNetworkSource *networkSource;
	ThreadWindow *threadWindow;
	ImageWindow *imageWindow;
	OpenBoardPanel *openBoardPanel;
	PreferencesWindow *preferencesWindow;
	NSString *displayedBoard;
	NSArray *displayedThreads;
	PostView *selectedOP;
	SubmitPostWindow *submitPostWindow;
}
-(void)refresh: (id)sender;
-(void)open: (id)sender;
-(void)postThread: (id)sender;
-(BOOL)validateMenuItem: (NSMenuItem*)menuItem;
-(void)didTapPreferences: (id)sender;
-(NSString*)getDisplayedBoard;
-(void)submitPostWindow: (SubmitPostWindow*)submitPostWindow didCreateNewThread: (Thread*)thread;
-(void)submitPostWindow: (SubmitPostWindow*)submitPostWindow didReplyToThread: (Thread*)thread withPost: (Post*)post;
@end
