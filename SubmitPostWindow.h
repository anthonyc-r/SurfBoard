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
#import "Data/Post.h"

@class SubmitPostWindow;
@protocol SubmitPostWindowDelegate
-(void)submitPostWindow: (SubmitPostWindow*)submitPostWindow didCreateNewThreadWithNumber: (NSNumber*)number onBoard: (NSString*)board;
-(void)submitPostWindow: (SubmitPostWindow*)submitPostWindow didReplyToPost: (Post*)post;
@end

@interface SubmitPostWindow: NSWindow {
	NSTextField *nameTextField;
	NSTextField *optionsTextField;
	NSTextField *subjectTextField;
	NSTextField *imageTextField;
	NSTextView *contentTextView;
	NSButton *postButton;
	NSButton *pickImageButton;
	PostNetworkSource *networkSource;
	Post *targetOP;
	NSString *targetBoard;
	id<SubmitPostWindowDelegate> delegate;
}

-(void)didTapPost: (id)sender;
-(void)didTapPickImage: (id)sender;
-(void)postSuccess: (id)sender;
-(void)postFailure: (NSError*)error;
-(void)configureForReplyingToOP: (Post*)op quotingPostNumbers: (NSArray*)postNumbers;
-(void)configureForNewThreadOnBoard: (NSString*)board;
-(void)setDelegate: (id<SubmitPostWindowDelegate>) aDelegate;
@end 
