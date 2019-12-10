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
#import "SubmitPostWindow.h"
#import "Net/PostNetworkSource.h"
#import "AppUserDefaults.h"

@implementation SubmitPostWindow

-(void)awakeFromNib {
	[super awakeFromNib];
	[nameTextField setStringValue: [AppUserDefaults userName]];
}

-(void)becomeKeyWindow {
	[super becomeKeyWindow];
	[self makeFirstResponder: contentTextView];
}

-(void)didTapPost: (id)sender {
	if (networkSource != nil) {
		NSLog(@"Post already in progress, ignoring.");
	}
	[self setTitle: @"Posting..."];
	NSString *name = [nameTextField stringValue];
	// Persist name upon posting...
	[AppUserDefaults setUserName: name];
	NSString *options = [optionsTextField stringValue];
	NSString *subject = [subjectTextField stringValue];
	NSString *content = [contentTextView string];
	// TODO: - Store or generate a single password per session
	NSString *password = [[NSUUID UUID] UUIDString];
	NSLog(@"Creating nw source");
	networkSource = [[PostNetworkSource alloc] initForThread: targetThread
		withName: name password: password subject: subject 
		comment: content];
	[networkSource performOnSuccess: @selector(postSuccess:) target: self];
	[networkSource performOnFailure: @selector(postFailure:) target: self];
	NSLog(@"Fetching nw source");
	[networkSource fetch];
}

-(void)configureForReplyingToThread: (Thread*)thread {
	[targetThread release];
	targetThread = thread;
	[targetThread retain];
	[self configureDefaultTitle];
}


-(void)postSuccess: (id)sender {
	NSLog(@"Successfully sent post!");
	[networkSource release];
	networkSource = nil;
	[self setTitle: @"Post Success!"];
	[self scheduleTitleConfigAfterDelay];
	[contentTextView setString: @""];
}

-(void)postFailure: (NSError*)error {
	NSLog(@"Failed to send post with error: %@", error);
	[networkSource release];
	networkSource = nil;
	[self setTitle: @"Post Failure"];
	[self scheduleTitleConfigAfterDelay];
}

-(void)scheduleTitleConfigAfterDelay {
	[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
		selector: @selector(configureDefaultTitle) userInfo: nil
		repeats: false];
}

-(void)configureDefaultTitle {
	if (targetThread != nil) {
		NSString *title = [NSString stringWithFormat: @"Reply To Thread #%@",
		[[targetThread getOP] getNumber]];
		[self setTitle: title];
	} else {
		[self setTitle: @"New Thread"];
	}
}

@end 
