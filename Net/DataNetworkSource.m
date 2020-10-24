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
#import "DataNetworkSource.h"
#import "NSURL+Utils.h"
#import "NSError+AppErrors.h"

@implementation DataNetworkSource

-(id)initWithURL: (NSURL*)aURL {
	if ((self = [super init])) {
		URL = aURL;
		[aURL retain];
		isCancelled = NO;
	}
	return self;
}

-(void)dealloc {
	[URL release];
	[super dealloc];
}

// TODO: - Consider adding general implementation for NetworkSource
-(void)cancel {
	isCancelled = YES;
}

-(NSURL*)URL {
	return URL;
}


-(NSDictionary*)additionalHeaders  {
	return nil;
}

-(void)makeSynchronousRequest {
	[self retain];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: URL];
	NSArray *headerKeys = [[self additionalHeaders] allKeys];
	NSString *key, *value;
	if (headerKeys != nil) {
		for (int i = 0; i < [headerKeys count]; i++) {
			key = [headerKeys objectAtIndex: i];
			value = [[self additionalHeaders] objectForKey: key];
			NSLog(@"setting header : %@: %@", key, value);
			[request setValue: value forHTTPHeaderField: key];
		}
	}
	// TODO: - Handle errors
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (isCancelled) {
		[self release];
		return;
	}
	if (error != nil) {
		NSLog(@"Error fetching image! %@", error);
		[self failure: error];
		return;
	}
	if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
		NSLog(@"Not httpurlres");
		[self failure: [NSError unexpectedResponseError]];
		return;
	}
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	NSLog(@"status code is %ld", [httpResponse statusCode]);
	if ([httpResponse statusCode] != 200) {
		NSLog(@"status code is error");
		[self failure: [NSError unexpectedResponseError]];
		return;
	}
	[self success: data];
	[self release];
}

@end
