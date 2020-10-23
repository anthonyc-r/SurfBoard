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
#import "PassLoginView.h"

@implementation PassLoginView

-(void)awakeFromNib {
	[super awakeFromNib];
	[self configureForNotActivated];
}

-(void)setDelegate: (id<PassLoginViewDelegate>)aDelegate {
	delegate = aDelegate;
}

-(void)configureForActivated {
	[deactivateButton setEnabled: YES];
	[activateButton setEnabled: NO];
	[tokenTextField setEnabled: NO];
	[pinTextField setEnabled: NO];
}

-(void)configureForNotActivated {
	[deactivateButton setEnabled: NO];
	[activateButton setEnabled: YES];
	[tokenTextField setEnabled: YES];
	[pinTextField setEnabled: YES];
}

-(void)didTapActivate: (id)sender {
	NSString *pin = [pinTextField stringValue];
	NSString *token = [tokenTextField stringValue];
	if ([pin length] < 1 || [token length] < 1) {
		return;
	}
	[delegate passLoginView: self
		 didRequestActivationWithToken: token
		 andPIN: pin];
}

-(void)didTapDeactivate: (id)sender {
	[delegate passLoginViewDidRequestDeactivation: self];
}

@end
