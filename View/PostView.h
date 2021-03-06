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
#import "Data/Post.h"
#import "Data/Thread.h"
#import "Net/DataNetworkSource.h"
#import "MediaManager.h"

@class PostView;

@protocol PostViewDelegate<NSTextViewDelegate>
-(void)postView: (PostView*)postView didTapViewOnThread: (Thread*)thread;
-(void)postView: (PostView*)postView didTapImageOnPost: (Post*)post;
-(void)postView: (PostView*)postView didSetSelected: (BOOL)isSelected forPost: (Post*)post;
@end

@interface PostView : NSView<MediaLoadingObserver>
{
  NSImageView *imageView;
  NSTextView *upperTextView;
  CGFloat maximumPostHeight;
  DataNetworkSource *activeImageSource;
  NSButton *viewButton;
  NSTextView *headlineLabel;
  Thread *displayedThread;
  Post *displayedPost;
  id<PostViewDelegate> delegate;
  NSColor *backgroundColor;
  NSButton *selectPostButton;
}
-(void)configureForPost: (Post*)post;
-(void)configureForThread: (Thread*)thread;
-(void)setPostBody: (NSString*)postBody;
-(void)setImage: (NSImage*)image;
-(CGFloat)getRequestedHeight;
-(void)didTapView;
-(void)setDelegate: (id<PostViewDelegate>)aDelegate;
-(void)didTapImage;
-(Post*)displayedPost;
-(void)setHighlight: (BOOL)highlight;
-(void)didChangeSelection: (NSButton*)sender;
-(void)deselect;
@end
