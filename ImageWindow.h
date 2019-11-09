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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Data/Post.h"
#import "Net/ImageNetworkSource.h"

@interface ImageWindow: NSWindow {
	NSImageView *imageView;
	ImageNetworkSource *networkSource;
}

-(void)loadImageForPost: (Post*)post;
-(void)onFetchImage: (NSImage*)image;
-(void)onFetchFail: (NSError*)error;

@end
