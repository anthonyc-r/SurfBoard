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


#import "NetworkSource.h"
#import "NSURL+Utils.h"
#import "PassNetworkSource.h"
#import "NSError+AppErrors.h"
#import "GNUstepBase/GSMime.h"

// Rando user agent string so we don't get bot rejection response
static NSString *const USER_AGENT = @"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0";
static NSString *const PASS_KEY = @"pass_id";
static NSString *const BODY_FORMAT = @"act=do_login&id=%@&pin=%@&long_login=1";

// Implementation which folds multiple Set-Cookie headers using the , character.

@implementation NSURLResponse (Additions)
-(void)_setHeaders: (id)headers {
	NSLog(@"Set headers!!");
	NSEnumerator *e;
	NSString *v;

	if ([headers isKindOfClass: [NSDictionary class]] == YES) {
		NSString *k;
		e = [(NSDictionary*)headers keyEnumerator];
		while ((k = [e nextObject]) != nil) {
			v = [(NSDictionary*)headers objectForKey: k];
			[self _setValue: v forHTTPHeaderField: k];
		}
	} else if ([headers isKindOfClass: [NSArray class]] == YES) {
		GSMimeHeader *h;
		e = [(NSArray*)headers objectEnumerator];
		NSMutableArray *cookies = [[NSMutableArray alloc] init];
		while ((h = [e nextObject]) != nil) {
			NSString *n = [h namePreservingCase: YES];
			NSString *v = [h fullValue];
			if ([n isEqualTo: @"Set-Cookie"]) {
				[cookies addObject: v];
			}
			[self _setValue: v forHTTPHeaderField: n];
		}
		if ([cookies count] > 1) {
			NSString *foldedCookies = [cookies componentsJoinedByString: @", "];
			NSLog(@"Folded cookies: %@", foldedCookies);
			[self _setValue: foldedCookies forHTTPHeaderField: @"Set-Cookie"];
		}
    	}
	[self _checkHeaders];
}

@end

@interface PassNetworkSource (private)
-(NSString*)extractPassIDFromCookie: (NSString*)cookie;
@end

@implementation PassNetworkSource

-(id)initWithToken: (NSString*)aToken pin: (NSString*)aPin {
	if ((self = [super init])) {
		token = aToken;
		pin = aPin;
	}
	return self;
}


-(void)makeSynchronousRequest {
	NSLog(@"Deleting cookies");
	
	NSArray *existingCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (int i = 0; i < [existingCookies count]; i++) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: 
			[existingCookies objectAtIndex: i]];
	}
	
	NSLog(@"Fetching pass");
	NSString *body = [NSString stringWithFormat: BODY_FORMAT, token, pin];
	NSURL *url = [NSURL urlForPassAuth];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
	[request setHTTPMethod: @"POST"];
	[request setHTTPShouldHandleCookies: YES];
	[request setHTTPBody: 
		[body dataUsingEncoding: NSASCIIStringEncoding]];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (error) {
		NSLog(@"Failure, err: %@", error);
		[self failure: error];
		return;
	}
	if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
		NSLog(@"failure resp not httpurl resp %@", response);
		[self failure: [NSError unexpectedResponseError]];
		return;
	}
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	NSDictionary *headers = [httpResponse allHeaderFields];
	NSString *cookies = [headers objectForKey: @"Set-Cookie"];
	NSString *passId = [self extractPassIDFromCookie: cookies];
	if (passId != nil) {
		NSLog(@"Succeeded with passId: %@", passId);
		[self success: passId];
	} else {
		[self failure: [NSError unexpectedResponseError]];
	}
}

-(NSString*)extractPassIDFromCookie: (NSString*)cookie {
	NSError *error = nil;
	NSString *pattern = @"pass_id=([0-9a-zA-Z.]+)";
	NSRegularExpression *exp = [[NSRegularExpression alloc] 
		initWithPattern: pattern
		options: 0
		error: &error
	];
	if (error != nil) {
		NSLog(@"Error in pass id regexp");
		return nil;
	}
	NSTextCheckingResult *res = [exp firstMatchInString: cookie
		options: 0
		range: NSMakeRange(0, [cookie length])];
	if (res == nil) {
		NSLog(@"pass id not found in cookie");
		return nil;
	}
	return [cookie substringWithRange: [res rangeAtIndex: 1]];
}

@end
