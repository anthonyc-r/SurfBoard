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
#import "CaptchaPanel.h"
#import "Net/CaptchaChallengeNetworkSource.h"
#import "Data/CaptchaChallenge.h"
#import "Net/CaptchaImageNetworkSource.h"

@implementation CaptchaPanel

-(void)onImageFetched: (NSData*)data {
	NSLog(@"Fetched image");
	NSImage *image = [[[NSImage alloc] initWithData: data] autorelease];
	[imageView setImage: image];
}

-(void)onImageFailed: (NSError*)error {
	NSLog(@"Failed to fetch image: %@", error);
}

-(void)onCaptchaFetched: (CaptchaChallenge*)aCaptcha { 
	NSLog(@"Fetched captcha");
	[captcha release];
	captcha = aCaptcha;
	[networkSource release];
	networkSource = nil;
	[hintLabel setStringValue: [captcha instructions]];
	[imageSource release];
	imageSource = [[CaptchaImageNetworkSource alloc] initWithURL: 
		[captcha imageGridURL]];
	[imageSource performOnSuccess: @selector(onImageFetched:) target: self];
	[imageSource performOnFailure: @selector(onImageFailed:) target: self];
	[imageSource makeSynchronousRequest];
	
}

-(void)onCaptchaFailed: (NSError*)error {
	NSLog(@"Failed to get captcha");
	[networkSource release];
	networkSource = nil;
}

-(void)fetchChallenge {
	networkSource = [[CaptchaChallengeNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(onCaptchaFetched:) target: self];
	[networkSource performOnFailure: @selector(onCaptchaFailed:) target: self];
	[networkSource makeSynchronousRequest];
}

-(void)makeKeyWindow {
	[super makeKeyWindow];
	NSLog(@"became key");
	if (captcha == nil && networkSource == nil) {
		[self fetchChallenge];
	}
}

-(void)didTapSubmit: (id)sender {
	NSLog(@"did tap submit");
}

-(void)didTapCheckbox: (id)sender {
	NSLog(@"did tap checkbox: %ld", [sender tag]);
}

@end