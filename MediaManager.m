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
	BOOL openedFromCache = [self tryToDisplayCachedFileForURL: aURL];
	if (openedFromCache) {
		NSLog(@"Viewed file from cache, won't make request");
	} else {
		[currentObserver mediaBeganLoading];
		networkSource = [[DataNetworkSource alloc] initWithURL: aURL];
		[networkSource performOnSuccess: @selector(onFetchMedia:) target:
			self];
		[networkSource performOnFailure: @selector(onFetchFail:) target:
			self];
		[networkSource fetch];
	}
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
	NSString *tmp = [self filePathForStoredMediaURL: [networkSource URL]];
	[data writeToFile: tmp atomically: NO];
	if ([AppUserDefaults isInternalViewerEnabled]) {
		NSLog(@"Internal viewer is enabled in prefs");
		[self tryInternalViewerToViewMedia: data];
	} else {
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

-(BOOL)tryToDisplayCachedFileForURL: (NSURL*)aURL {
	NSString *path = [self filePathForStoredMediaURL: aURL];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: path];
	NSLog(@"path for cached media: %@, fileExists: %d", path, fileExists);
	// Return early, no saved file.
	if (!fileExists) {
		return NO;
	}
	BOOL preferInternalViewer = [AppUserDefaults isInternalViewerEnabled];
	// Try nsworkspace first and return on success
	if (!preferInternalViewer) {
		if ([[NSWorkspace sharedWorkspace] openFile: path]) {
			return YES;
		}
	}
	// Didn't succeed, so fall back to internal viewer
	NSData *data = [[NSFileManager defaultManager] contentsAtPath: path];
	return [self tryInternalViewerToViewMedia: data];
}

-(BOOL)tryInternalViewerToViewMedia: (NSData*)data {
	NSLog(@"Falling back to internal viewer");
	if (data == nil) {
		NSLog(@"Data was nil");
		return NO;
	}
	NSImage *image = [[[NSImage alloc] initWithData: data] autorelease];
	if (image != nil) {
		[imageWindow loadImage: image];
		return YES;
	} else {
		return NO;
	}
}

-(NSString*)filePathForStoredMediaURL: (NSURL*)aURL {
	NSString *fileName = [aURL lastPathComponent];
	NSString *tmp = [NSTemporaryDirectory()
		stringByAppendingPathComponent: TMP_DIR];
	[[NSFileManager defaultManager] createDirectoryAtPath: tmp attributes: 
		nil];
	return [tmp stringByAppendingPathComponent: fileName];
}

@end
