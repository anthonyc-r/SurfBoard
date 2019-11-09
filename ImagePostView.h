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
#import "Net/ImageNetworkSource.h"

@class ImagePostView;

@protocol ImagePostViewDelegate
-(void)imagePostView: (ImagePostView*)imagePostView didTapViewOnThread: (Thread*)thread;
-(void)imagePostView: (ImagePostView*)imagePostView didTapImageOnPost: (Post*)post;
@end

@interface ImagePostView : NSView
{
  NSImageView *imageView;
  NSTextView *upperTextView;
  CGFloat maximumPostHeight;
  ImageNetworkSource *activeImageSource;
  NSButton *viewButton;
  Thread *displayedThread;
  Post *displayedPost;
  id<ImagePostViewDelegate> delegate;
}
-(void)configureForPost: (Post*)post;
-(void)configureForThread: (Thread*)thread;
-(void)setPostBody: (NSString*)postBody;
-(void)setImage: (NSImage*)image;
-(CGFloat)getRequestedHeight;
-(CGFloat)getMaximumPostHeight;
-(void)setMaximumPostHight: (CGFloat)height;
-(void)didTapView;
-(void)setDelegate: (id<ImagePostViewDelegate>)aDelegate;
-(void)didTapImage;
@end
