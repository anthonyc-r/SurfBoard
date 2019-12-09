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
#import "Net/PostNetworkSource.h"
#import "Data/Thread.h"

@interface SubmitPostWindow: NSWindow {
	NSTextField *nameTextField;
	NSTextField *optionsTextField;
	NSTextField *subjectTextField;
	NSTextView *contentTextView;
	NSButton *postButton;
	PostNetworkSource *networkSource;
	Thread *targetThread;
}

-(void)didTapPost: (id)sender;
-(void)postSuccess: (id)sender;
-(void)postFailure: (NSError*)error;
-(void)configureForReplyingToThread: (Thread*)thread;

@end 
