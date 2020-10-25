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
#import "Data/CaptchaChallenge.h"
#import "Net/CaptchaChallengeNetworkSource.h"
#import "Net/CaptchaImageNetworkSource.h"

@interface CaptchaPanel: NSPanel {
	BOOL selection[9];
	id imageView;
	id hintLabel;
	CaptchaChallenge *captcha;
	CaptchaChallengeNetworkSource *networkSource;
	CaptchaImageNetworkSource *imageSource;
}

-(void)didTapSubmit: (id)sender;
-(void)didTapCheckbox: (id)sender;

@end