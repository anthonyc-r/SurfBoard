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
#import "MediaManager.h"
#import "ImageWindow.h"
#import "AppUserDefaults.h"

static NSString *const TMP_DIR = @"surfboard";

@implementation MediaManager

-(void)displayMediaAtURL: (NSURL*)aURL observer: (NSObject<MediaLoadingObserver>*)anObserver {
	[self setObserver: anObserver];
	[self displayMediaAtURL: aURL];
}

-(void)displayMediaAtURL: (NSURL*)aURL {
	NSLog(@"Handle media for url: %@", aURL);
	// Download media data
	if (networkSource != nil) {
		NSLog(@"Already downloading media, skipping");
		return;
	}
	[currentObserver mediaBeganLoading];
	networkSource = [[DataNetworkSource alloc] initWithURL: aURL];
	[networkSource performOnSuccess: @selector(onFetchMedia:) target: self];
	[networkSource performOnFailure: @selector(onFetchFail:) target: self];
	[networkSource fetch];
}

-(void)setObserver: (NSObject<MediaLoadingObserver>*)anObserver {
	[currentObserver release];
	currentObserver = anObserver;
	[currentObserver retain];
}

-(void)onFetchMedia: (NSData*)data {
	[currentObserver mediaFinishedLoading];
	[self setObserver: nil];
	NSLog(@"on fetched media");
	if ([AppUserDefaults isInternalViewerEnabled]) {
		NSLog(@"Internal viewer is enabled in prefs");
		[self tryInternalViewerToViewMedia: data];
	} else {
		NSString *fileName = [[networkSource URL] lastPathComponent];
		NSString *tmp = [NSTemporaryDirectory()
			stringByAppendingPathComponent: TMP_DIR];
		[[NSFileManager defaultManager] createDirectoryAtPath: tmp
			attributes: nil];
		tmp = [tmp stringByAppendingPathComponent: fileName];
		[data writeToFile: tmp atomically: NO];
		BOOL opened = [[NSWorkspace sharedWorkspace] openFile: tmp];
		if (!opened) {
			NSLog(@"Failed to temporarily save media to %@", tmp);
			[self tryInternalViewerToViewMedia: data];
		}
	}
	[networkSource release];
	networkSource = nil;
}

-(void)onFetchFail: (NSError*)error {
	[currentObserver mediaFinishedLoading];
	[self setObserver: nil];
	NSLog(@"error loading image: %@", error);
	[networkSource release];
	networkSource = nil;
}

-(void)tryInternalViewerToViewMedia: (NSData*)data {
	NSLog(@"Falling back to internal viewer");
	NSImage *image = [[[NSImage alloc] initWithData: data] autorelease];
	[imageWindow loadImage: image];
}

@end
