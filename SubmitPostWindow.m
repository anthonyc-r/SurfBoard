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

-(void)dealloc {
	[targetBoard release];
	[targetOP release];
	[super dealloc];
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
	if (targetOP != nil) {
		networkSource = [[PostNetworkSource alloc] initForOP: targetOP
			withName: name password: password subject: subject 
			comment: content options: options imageURL: [self
			selectedImageURL]];
	} else {
		networkSource = [[PostNetworkSource alloc] 
			initForBoard: targetBoard
			withName: name password: password subject: subject 
			comment: content options: options imageURL: [self
			selectedImageURL]];
	}
	[networkSource performOnSuccess: @selector(postSuccess:) target: self];
	[networkSource performOnFailure: @selector(postFailure:) target: self];
	NSLog(@"Fetching nw source");
	[networkSource fetch];
}

-(void)didTapPickImage: (id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setDirectory: NSHomeDirectory()];
	[openPanel setAllowedFileTypes: [NSArray arrayWithObjects:
		@"jpeg", @"jpg", @"gif", @"png", @"webm", nil]];
	[openPanel runModal];
	NSURL *fileURL = [openPanel URL];
	NSLog(@"Picked file: %@", fileURL);
	[imageTextField setStringValue: [fileURL path]];
}

-(void)configureForReplyingToOP: (Post*)op quotingPostNumbers: (NSArray*)postNumbers {
	[targetBoard release];
	targetBoard = nil;
	[targetOP release];
	targetOP = op;
	[targetOP retain];
	[self configureDefaultTitle];
	NSMutableString *content = [[NSMutableString alloc] init];
	[content autorelease];
	NSNumber *postNumber = nil;
	NSEnumerator *enumerator = [postNumbers objectEnumerator];
	while ((postNumber = [enumerator nextObject])) {
		NSString *quote = [NSString 
			stringWithFormat: @">>%@\n", postNumber];
		[content appendString: quote];
	}
	[contentTextView setString: content];
}

-(void)configureForNewThreadOnBoard: (NSString*)board {
	[targetOP release];
	targetOP = nil;
	[targetBoard release];
	targetBoard = board;
	[targetBoard retain];
	[self configureDefaultTitle];
}


-(void)postSuccess: (id)sender {
	NSLog(@"Successfully sent post!");
	[networkSource release];
	networkSource = nil;
	[self setTitle: @"Post Success!"];
	[self scheduleTitleConfigAfterDelay];
	[contentTextView setString: @""];
	[imageTextField setStringValue: @""];
	if (targetOP != nil) {
		[delegate submitPostWindow: self didReplyToPost: targetOP];
	} else if ([sender isKindOfClass: [NSNumber class]]) {
		[delegate submitPostWindow: self didCreateNewThreadWithNumber:
			sender onBoard: targetBoard];
	}
	// TODO: - Handle potential errors.
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
	if (targetOP != nil) {
		NSString *title = [NSString stringWithFormat: @"Reply To Thread #%@",
		[targetOP getNumber]];
		[self setTitle: title];
	} else {
		NSString *title = [NSString stringWithFormat: @"New Thread /%@/", targetBoard];
		[self setTitle: title];
	}
}

-(NSURL*)selectedImageURL {
	NSString *path = [imageTextField stringValue];
	if (path == nil || [path length] < 1) {
		return nil;
	}
	return [NSURL fileURLWithPath: path];
}

-(void)setDelegate: (id<SubmitPostWindowDelegate>) aDelegate {
	delegate = aDelegate;
}

@end 
