/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "MainWindow.h"
#include "ImagePostView.h"
#include "NSView+NibLoadable.h"

@implementation MainWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	NSLog(@"MainWindow loaded.");
	ImagePostView *imagePostView = [ImagePostView loadFromNibNamed: @"ImagePostView" owner: NSApp];
	[[self contentView] addSubview: imagePostView];
}

@end
