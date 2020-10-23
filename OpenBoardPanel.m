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
#import "OpenBoardPanel.h"

@implementation OpenBoardPanel

-(void)awakeFromNib {
	[super awakeFromNib];
	[textField setDelegate: self];
	[okButton setKeyEquivalent: @"\r"];
}

-(void)becomeKeyWindow {
	[super becomeKeyWindow];
	[self makeFirstResponder: textField];
	[textField selectText: self];
}

-(void)didTapOK: (id)sender {
	[pickedValue release];
	pickedValue = [textField stringValue];
	[pickedValue retain];
	[self close];
}


-(void)didTapCancel: (id)sender {
	pickedValue = nil;
	[self close];
}

-(NSString*)pickedValue {
	return pickedValue;
}

-(void)controlTextDidEndEditing: (NSControl*)control {
	[self makeFirstResponder: okButton];;
}

@end
