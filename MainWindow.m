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

@implementation MainWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"MainWindow loaded.");
	ImagePostView *imagePostView = [ImagePostView loadFromNibNamed: @"ImagePostView" owner: NSApp];
	[imagePostView setPostBody: @"Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post body!!!Test post b"];
	[[self contentView] addSubview: imagePostView];
}

@end
