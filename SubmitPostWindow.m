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

@implementation SubmitPostWindow

-(void)didTapPost: (id)sender {
	NSLog(@"Did tap post");
	if (networkSource != nil) {
		NSLog(@"Post already in progress, ignoring.");
	}
	NSString *name = [nameTextField stringValue];
	NSString *options = [optionsTextField stringValue];
	NSString *subject = [subjectTextField stringValue];
	NSLog(@"contentView: %@", contentTextView);
	NSString *content = [contentTextView string];
	NSLog(@"Content: - %@", content);
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
}


-(void)postSuccess: (id)sender {
	NSLog(@"Successfully sent post!");
	[networkSource release];
	networkSource = nil;
}

-(void)postFailure: (NSError*)error {
	NSLog(@"Failed to send post with error: %@", error);
	[networkSource release];
	networkSource = nil;
}

@end 
