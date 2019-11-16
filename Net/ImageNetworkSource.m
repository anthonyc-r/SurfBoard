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
#import "ImageNetworkSource.h"
#import "NSURL+Utils.h"

@implementation ImageNetworkSource

-(id)initWithURL: (NSURL*)aURL {
	if ((self = [super init])) {
		URL = aURL;
		[aURL retain];
	}
	return self;
}

-(void)dealloc {
	[super dealloc];
	[URL release];
}

-(void)makeSynchronousRequest {
	NSURLRequest *request = [NSURLRequest requestWithURL: URL];
	// TODO: - Handle errors
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (error != nil) {
		NSLog(@"Error fetching image! %@", error);
		[self failure: error];
		return;
	}
	NSImage *image = [[NSImage alloc] initWithData: data];
	[self success: image];
	[image release];
}


@end
