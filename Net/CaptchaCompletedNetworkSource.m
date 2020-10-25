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
#import "CaptchaCompletedNetworkSource.h"
#import "NSURL+Utils.h"
#import "Data/CaptchaChallenge.h"
#import "NSError+AppErrors.h"

static NSString *const FORM_DELIM = @"987210948";
static NSString *const USER_AGENT = @"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36";
static NSString *const ACCEPT_ENCODE = @"Accept-Encoding: deflate, br";
static NSString *const ACCEPT_LANG = @"Accept-Language: en-US";
static NSString *const COOKIE = @"NID=87=gkOAkg09AKnvJosKq82kgnDnHj8Om2pLskKhdna02msog8HkdHDlasDf";
static NSString *const ACCEPT = @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3";

@implementation CaptchaCompletedNetworkSource 

-(id)initWithChallenge: (CaptchaChallenge*)aCompletedChallenge {
	if ((self = [super init])) {
		challenge = aCompletedChallenge;
		[challenge retain];
	}
	return self;
}

-(void)dealloc {
	[challenge release];
	[super dealloc];
}

-(NSString*)bodyContentForTextField: (NSString*)field withValue: (NSString*)value {
	return [NSString stringWithFormat: @"--%@\nContent-Disposition: form-data; name=\"%@\"\n\n%@\n", FORM_DELIM, field, value];
}

// TODO: - Consider creating a more general 'multipart form-data' network source.
-(void)makeSynchronousRequest {
	NSURL *url = [NSURL urlForCaptchaChallenge];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
	[request setHTTPMethod: @"POST"];
	[request setValue: [url absoluteString] forHTTPHeaderField:
		@"Referer"];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	[request setValue: ACCEPT forHTTPHeaderField: @"Accept"];
	[request setValue: ACCEPT_ENCODE forHTTPHeaderField: 
		@"Accept-Encoding"];
	[request setValue: ACCEPT_LANG forHTTPHeaderField:
		@"Accept-Language"];
	[request setValue: COOKIE forHTTPHeaderField: @"Cookie"];

	NSString *contentType = [NSString stringWithFormat: 
		@"multipart/form-data; boundary=\"%@\"", FORM_DELIM];
	[request setValue: contentType forHTTPHeaderField: @"Content-Type"];
	NSMutableString *postBody = [[NSMutableString new] autorelease];

	[postBody appendString: [self bodyContentForTextField: @"c"
				withValue: [challenge key]]];
	for (int i = 0; i < [challenge imageCount]; i++) {
		if ([challenge isImageSelectedAtIndex: i]) {
			[postBody appendString: [self bodyContentForTextField: @"response"
				withValue: [NSString stringWithFormat: @"%d", i]]];
		}
	}


	NSMutableData *postBodyData = [[postBody dataUsingEncoding:
		NSASCIIStringEncoding] mutableCopy];
	[postBodyData appendData: [[NSString stringWithFormat: 
			@"--%@\n", FORM_DELIM] dataUsingEncoding: 
			NSASCIIStringEncoding]];

	[request setHTTPBody: postBodyData];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (error != nil || data == nil) {
		NSLog(@"Error making request: %@", error);
		[self failure: [NSError unexpectedResponseError]];
		return;
	}
	NSString *responseString = [[NSString alloc] initWithData: data
		encoding: NSUTF8StringEncoding];
	NSLog(@"response: %@", responseString);
}

@end