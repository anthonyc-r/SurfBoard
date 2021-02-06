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
#import "PreferencesWindow.h"
#import "View/PassLoginView.h"
#import "View/NSView+NibLoadable.h"
#import "Data/Pair.h"
#import "Net/PassNetworkSource.h"
#import "AppUserDefaults.h"

@implementation PreferencesWindow

-(void)dealloc {
	[preferences release];
	[networkSource release];
	[super dealloc];
}
	
-(void)awakeFromNib {
	preferences = [[NSMutableArray alloc] init];
	loginView = [PassLoginView loadFromNibNamed: @"PassLoginView"];
	[loginView setDelegate: self];
	if ([self isPassActivated]) {
		[loginView configureForActivated];
	} else {
		[loginView configureForNotActivated];
	}
	
	mediaPreferencesView = [MediaPreferencesView loadFromNibNamed:
		@"MediaPreferencesView"];
	[mediaPreferencesView setDelegate: self];
	[mediaPreferencesView setInternalViewerSwitchOn: [AppUserDefaults
		isInternalViewerEnabled]];
	
	[preferenceButton removeAllItems];
	[preferenceButton setTarget: self];
	[preferenceButton setAction: @selector(didPickPreference)];
	[self addPreferenceView: loginView withTitle: @"4Chan Pass"];
	[self addPreferenceView: mediaPreferencesView withTitle: @"Media"];
}

-(void)didPickPreference {
	NSString *title = [preferenceButton stringValue];
	NSLog(@"Control text: %@", title);
	NSEnumerator *enumerator = [preferences objectEnumerator];
	Pair *pref;
	while ((pref = [enumerator nextObject])) {
		if ([[pref firstObject] isEqualToString: title]) {
			break;
		}
		pref = nil;
	}
	if (pref != nil && [pref secondObject] != [containerView contentView]) {
		NSLog(@"Setting container view content to %@", 
			[pref secondObject]);
		[containerView setContentView: [pref secondObject]];
	} else {
		NSLog(@"No pref view or already in container");
	}
}

-(void)addPreferenceView: (NSView*)view withTitle: (NSString*)title {
	Pair *pref = [[Pair alloc] initWithFirstObject: title secondObject: view];
	[pref autorelease];
	if ([preferences count] < 1) {
		[containerView setContentView: view];
	}
	[preferenceButton addItemWithTitle: title];
	[preferences addObject: pref];
}

-(void)passLoginView: (PassLoginView*)passLoginView didRequestActivationWithToken: (NSString*)token andPIN: (NSString*)PIN {
	NSLog(@"Did request activation for pin %@, token: %@", token, PIN);
	if (networkSource != nil) {
		NSLog(@"Request in progress, skipping");
		return;
	}
	networkSource = [[PassNetworkSource alloc] initWithToken: token
		pin: PIN];
	[networkSource retain];
	[networkSource performOnSuccess: @selector(didFetchPassID:) target: self];
	[networkSource performOnFailure: @selector(failedToFetchPassID:)
		target: self];
	[networkSource fetch];
}

-(void)passLoginViewDidRequestDeactivation: (PassLoginView*)passLoginView {
	NSLog(@"Did request deactivation");
	[AppUserDefaults setPassID: nil];
	[loginView configureForNotActivated];
}

-(BOOL)isPassActivated {
	NSString *passID = [AppUserDefaults passID];
	return passID != nil;
}

-(void)didFetchPassID: (NSString*)passID {
	[networkSource release];
	networkSource = nil;
	[AppUserDefaults setPassID: passID];
	[loginView configureForActivated];
}

-(void)failedToFetchPassID: (NSError*)error {
	[networkSource release];
	networkSource = nil;
	NSLog(@"Failed to fetch pass with error %@", error);
}

-(void)mediaPreferencesView: (MediaPreferencesView*)mediaPreferencesView didSetInternalViewerEnabled: (BOOL)isEnabled {
	[AppUserDefaults setInternalViewerEnabled: isEnabled];
}

@end
