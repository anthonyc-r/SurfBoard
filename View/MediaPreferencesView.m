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
#import "MediaPreferencesView.h"

@implementation MediaPreferencesView

-(void)awakeFromNib {
	[internalViewerSwitch setTarget: self];
	[internalViewerSwitch setAction: @selector(didTapEnableViewerButton:)];
}

-(void)setInternalViewerSwitchOn: (BOOL)isOn {
	if (isOn) {
		[internalViewerSwitch setState: NSOnState];
	} else {
		[internalViewerSwitch setState: NSOffState];
	}
}

-(void)setDelegate: (id<MediaPreferencesViewDelegate>)aDelegate {
	delegate = aDelegate;
}

-(void)didTapEnableViewerButton: (NSButton*)button {
	BOOL isEnabled = [button state] == NSOnState;
	[delegate mediaPreferencesView: self didSetInternalViewerEnabled:
		isEnabled];
}

@end
