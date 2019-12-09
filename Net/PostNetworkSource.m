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
#import "PostNetworkSource.h"
#import "NSError+AppErrors.h"
#import "NSURL+Utils.h"

static NSString *const USER_AGENT = @"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0";
static NSString *const NEW_THREAD_BODY_FORMAT = @"mode=regist&name=%@&sub=%@&com=%@&pwd=%@";
static NSString *const REPLY_BODY_FORMAT = @"mode=regist&resto=%@&name=%@&sub=%@&com=%@&pwd=%@";
static NSString *const COOKIE = @"pass_id=%@; pass_enabled=1";

@implementation PostNetworkSource

-(id)initForThread: (Thread*)aThread withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment {
	if ((self = [super init])) {
		thread = aThread;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
		[thread retain];
	}
	return self;
}

-(id)initForBoard: (NSString*)aBoard withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment{
	if ((self = [super init])) {
		board = aBoard;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		[board retain];
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
	}
	return self;
}



-(void)makeSynchronousRequest {
	NSLog(@"Will make post!");
	NSString *passId = [[NSUserDefaults standardUserDefaults]
		objectForKey: @"pass_id"];
	if (passId == nil) {
		[self failure: [NSError noPassError]];
		return;
	}
	NSString *boardCode;
	NSString *postBody;
	if (thread != nil) {
		boardCode = [[thread getOP] getBoard];
		NSNumber *postNumber = [[thread getOP] getNumber];
		postBody = [NSString stringWithFormat: REPLY_BODY_FORMAT,
		postNumber, name, subject, comment, password];
	} else {
		boardCode = board;
		postBody = [NSString stringWithFormat: NEW_THREAD_BODY_FORMAT,
		name, subject, comment, password];
	}
	NSURL *url = [NSURL urlForPostingToBoard: board];
	NSMutableURLRequest *request = [NSMutableURLRequest 
		requestWithURL: url];
	[request setHTTPBody: [postBody 
		dataUsingEncoding: NSASCIIStringEncoding]];
	[request setHTTPMethod: @"POST"];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	NSString *cookie = [NSString stringWithFormat: COOKIE, passId];
	NSLog(@"Cookie: %@", cookie);
	[request setValue: cookie forHTTPHeaderField: @"Cookie"];
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
	[responseString autorelease];
	NSLog(@"Response data: %@", responseString);
	[self failure: [NSError unexpectedResponseError]];
}

@end
