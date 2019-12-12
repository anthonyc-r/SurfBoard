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
#import "Data/Post.h"
#import "NSError+AppErrors.h"
#import "NSURL+Utils.h"

static NSString *const USER_AGENT = @"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0";
static NSString *const NEW_THREAD_BODY_FORMAT = @"mode=regist&name=%@&sub=%@&com=%@&pwd=%@&email=%@";
static NSString *const REPLY_BODY_FORMAT = @"mode=regist&resto=%@&name=%@&sub=%@&com=%@&pwd=%@&email=%@";
static NSString *const COOKIE = @"pass_id=%@; pass_enabled=1";
static NSString *const SUCCESS_TOKEN = @"<title>Post successful!</title>";

@implementation PostNetworkSource

-(id)initForOP: (Post*)anOP withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions {
	if ((self = [super init])) {
		op = anOP;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		options = someOptions;
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
		[op retain];
		[options retain];
	}
	return self;
}

-(id)initForBoard: (NSString*)aBoard withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions {
	if ((self = [super init])) {
		board = aBoard;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		options = someOptions;
		[board retain];
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
		[options retain];
	}
	return self;
}

-(void)dealloc {
	[board release];
	[op release];
	[name release];
	[password release];
	[subject release];
	[comment release];
	[options release];
	[super dealloc];
}



-(void)makeSynchronousRequest {
	NSString *passId = [[NSUserDefaults standardUserDefaults]
		objectForKey: @"pass_id"];
	if (passId == nil) {
		[self failure: [NSError noPassError]];
		return;
	}
	NSString *boardCode;
	NSString *postBody;
	if (op != nil) {
		boardCode = [op getBoard];
		NSNumber *postNumber = [op getNumber];
		postBody = [NSString stringWithFormat: REPLY_BODY_FORMAT,
		postNumber, name, subject, comment, password, options];
	} else {
		boardCode = board;
		postBody = [NSString stringWithFormat: NEW_THREAD_BODY_FORMAT,
		name, subject, comment, password, options];
	}
	NSURL *url = [NSURL urlForPostingToBoard: boardCode];
	NSMutableURLRequest *request = [NSMutableURLRequest 
		requestWithURL: url];
	[request setHTTPBody: [postBody 
		dataUsingEncoding: NSASCIIStringEncoding]];
	[request setHTTPMethod: @"POST"];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	NSString *cookie = [NSString stringWithFormat: COOKIE, passId];
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
	NSRange range = [responseString rangeOfString: SUCCESS_TOKEN];
	NSLog(@"Response data: %@", responseString);
	if (range.location != NSNotFound) {
		[self success: self];
	} else {
		[self failure: [NSError unexpectedResponseError]];
	}
}

@end
