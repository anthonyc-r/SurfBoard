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
#import "ImageWindow.h"
#import "Net/NSURL+Utils.h"
#import "View/DraggableImageView.h"

@implementation ImageWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSRect bounds = [[self contentView] bounds];
	imageView = [[DraggableImageView alloc] initWithFrame: bounds];
	[imageView setAnimates: YES];
	[imageView setImageScaling: NSImageScaleProportionallyUpOrDown];
	[scrollView setDocumentView: imageView];
	[scrollView setHasHorizontalScroller: NO];
	[scrollView setHasVerticalScroller: NO];
}

-(void)loadImage: (NSImage*)image {
	NSLog(@"Image window fetched image, %@", image);
	[imageView setImage: image];
	NSRect bounds = [[self contentView] bounds];
	[imageView setFrame: bounds];
	[self makeKeyAndOrderFront: self];
}

@end
