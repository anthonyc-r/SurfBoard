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

-(void)dealloc {
	[result release];
	[super dealloc];
}

-(void)onCaptchaCompleted: (NSString*)aResult {
	NSLog(@"Captcha completed with result: %@", aResult);
	[result release];
	result = aResult;
	[result retain];
	[self close];
}

-(void)onCaptchaFailed: (NSError*)error {
	NSLog(@"Captcha failed: %@", error);
	[self close];
}

-(void)onImageFetched: (NSData*)data {
	NSLog(@"Fetched image");
	NSImage *image = [[[NSImage alloc] initWithData: data] autorelease];
	[imageView setImage: image];
	[imageSource release];
	imageSource = nil;
}

-(void)onImageFailed: (NSError*)error {
	NSLog(@"Failed to fetch image: %@", error);
	[imageSource release];
	imageSource = nil;
}

-(void)onFetchedCaptcha: (CaptchaChallenge*)aCaptcha { 
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

-(void)onFetchChallengeFailed: (NSError*)error {
	NSLog(@"Failed to get captcha");
	[networkSource release];
	networkSource = nil;
}

-(void)fetchChallenge {
	networkSource = [[CaptchaChallengeNetworkSource alloc] init];
	[networkSource performOnSuccess: @selector(onFetchedCaptcha:) target: self];
	[networkSource performOnFailure: @selector(onFetchChallengeFailed:) target: self];
	[networkSource makeSynchronousRequest];
}

-(void)clearCheckboxes {
	id view;
	NSArray *subviews = [[self contentView] subviews];
	for (int i = 0; i < [subviews count]; i++) {
		view = [subviews objectAtIndex: i];
		if ([view isKindOfClass: [NSButton class]]) {
			[view setState: NSOffState];
		}
	}
}

-(void)makeKeyWindow {
	[super makeKeyWindow];
	NSLog(@"became key");
	if (captcha == nil && networkSource == nil) {
		[self clearCheckboxes];
		[self fetchChallenge];
	}
}

-(void)close {
	[super close];
	[imageView setImage: nil];
	[hintLabel setStringValue: @"Loading..."];
	[captcha release];
	captcha = nil;
	[networkSource release];
	networkSource = nil;
}

-(void)didTapSubmit: (id)sender {
	NSLog(@"did tap submit");
	if (![captcha isValid]) {
		NSLog(@"No valid captcha to submit");
		return;
	}
	NSLog(@"will make req,...");
	completedSource = [[CaptchaCompletedNetworkSource alloc] initWithChallenge: captcha];
	[completedSource performOnSuccess: @selector(onCaptchaCompleted:) target: self];
	[completedSource performOnFailure: @selector(onCaptchaFailed:) target: self];
	[completedSource makeSynchronousRequest];
}

-(void)didTapCheckbox: (id)sender {
	NSLog(@"did tap checkbox: %ld", [sender tag]);
	BOOL isSelected = [sender state] == NSOnState;
	[captcha setImageSelected: isSelected atIndex: [sender tag]];

}

-(NSString*)result {
	return result;
}	

-(NSString*)challenge {
	return [captcha key];
}

@end