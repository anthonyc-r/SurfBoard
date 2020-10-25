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
#import "Data/Thread.h"
#import "NSError+AppErrors.h"
#import "NSURL+Utils.h"

static NSString *const FORM_DELIM = @"987210948";
static NSString *const USER_AGENT = @"Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0";
static NSString *const NEW_THREAD_BODY_FORMAT = @"mode=regist&name=%@&sub=%@&com=%@&pwd=%@&email=%@";
static NSString *const REPLY_BODY_FORMAT = @"mode=regist&resto=%@&name=%@&sub=%@&com=%@&pwd=%@&email=%@";
static NSString *const COOKIE = @"pass_id=%@; pass_enabled=1";
static NSString *const SUCCESS_TOKEN = @"<title>Post successful!</title>";

@implementation PostNetworkSource

-(id)initForOP: (Post*)anOP withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions imageURL: (NSURL*)anImageURL {
	if ((self = [super init])) {
		op = anOP;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		options = someOptions;
		imageURL = anImageURL;
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
		[op retain];
		[options retain];
		[imageURL retain];
	}
	return self;
}

-(id)initForBoard: (NSString*)aBoard withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions imageURL: (NSURL*)anImageURL {
	if ((self = [super init])) {
		board = aBoard;
		name = aName;
		password = aPassword;
		subject = aSubject;
		comment = aComment;
		options = someOptions;
		imageURL = anImageURL;
		[board retain];
		[name retain];
		[password retain];
		[subject retain];
		[comment retain];
		[options retain];
		[imageURL retain];
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
	[imageURL release];
	[super dealloc];
}

-(void)setPassId: (NSString*)aPassId {
	[passId release];
	passId = aPassId;
	[passId retain];
}

-(void)setCaptchaId: (NSString*)aCaptchaId forChallenge: (NSString*)aCaptchaChallenge {
	[captchaId release];
	captchaId = aCaptchaId;
	[captchaId retain];
	[captchaChallenge release];
	captchaChallenge = aCaptchaChallenge;
	[captchaChallenge retain];
}


-(void)makeSynchronousRequest {
	if (passId == nil && captchaId == nil) {
		[self failure: [NSError noPassError]];
		return;
	}
	NSURL *url = [NSURL urlForPostingToBoard: [self boardCode]];
	NSLog(@"post to url: %@", url);
	NSMutableURLRequest *request = [NSMutableURLRequest 
		requestWithURL: url];
		
	[request setHTTPMethod: @"POST"];
	[request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
	if (passId != nil) {
		NSString *cookie = [NSString stringWithFormat: COOKIE, passId];
		[request setValue: cookie forHTTPHeaderField: @"Cookie"];
	}
	// TODO: - consider abstracting this http multipart form construction
	// TODO: - random, long, boundary.;
	NSString *contentType = [NSString stringWithFormat: 
		@"multipart/form-data; boundary=\"%@\"", FORM_DELIM];
	[request setValue: contentType forHTTPHeaderField: @"Content-Type"];

	NSString *textFieldBody;
	if (op != nil) {
		NSNumber *postNumber = [op getNumber];
		textFieldBody = [NSString stringWithFormat: REPLY_BODY_FORMAT,
		postNumber, name, subject, comment, password, options];
	} else {
		textFieldBody = [NSString stringWithFormat: 
			NEW_THREAD_BODY_FORMAT, name, subject, comment,
			password, options];
	}
	NSMutableString *postBody = [[NSMutableString new] autorelease];
	[postBody appendString: [self bodyContentForTextField: @"MAX_FILE_SIZE"
		withValue: @"4194304"]];
	[postBody appendString: [self bodyContentForTextField: @"mode"
		withValue: @"regist"]];
	[postBody appendString: [self bodyContentForTextField: @"pwd"
		withValue: password]];
	if (op != nil) {
		NSString *postNumber = [[op getNumber] description];
		[postBody appendString: [self bodyContentForTextField: @"resto"
			withValue: postNumber]];
	} else {
		[postBody appendString: [self bodyContentForTextField: @"sub"
			withValue: subject]];
	}
	[postBody appendString: [self bodyContentForTextField: @"name"
		withValue: name]];
	[postBody appendString: [self bodyContentForTextField: @"email"
		withValue: options]];
	[postBody appendString: [self bodyContentForTextField: @"com"
		withValue: comment]];
	if (captchaId != nil) {
		NSLog(@"captcha set, id is: %@", captchaId);
		[postBody appendString: [self bodyContentForTextField: 
			@"g-recaptcha-response" withValue: captchaId]];
		//[postBody appendString: [self bodyContentForTextField:
		//	@"recaptcha_response_field" withValue: captchaId]];
	}
	

	[postBody appendFormat: @"--%@\n", FORM_DELIM];
	[postBody appendFormat: @"Content-Disposition: form-data; name=\"upfile\"; filename=\"%@\"\n", [self filename]];
	[postBody appendFormat: @"Content-Type: %@\n\n", 
		[self fileMimeType]];
	
	NSMutableData *postBodyData = [[postBody dataUsingEncoding:
		NSASCIIStringEncoding] mutableCopy];
	if (imageURL != nil) {
		[postBodyData appendData: [NSData dataWithContentsOfURL:
			imageURL]];
		[postBodyData appendData: [[NSString stringWithFormat: 
			@"\n--%@--\n", FORM_DELIM] dataUsingEncoding: 
			NSASCIIStringEncoding]];
	} else {
		[postBodyData appendData: [[NSString stringWithFormat: 
			@"--%@\n", FORM_DELIM] dataUsingEncoding: 
			NSASCIIStringEncoding]];
	}
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
	[responseString autorelease];
	NSRange range = [responseString rangeOfString: SUCCESS_TOKEN];
	//NSLog(@"Response data: %@", responseString);
	if (range.location != NSNotFound) {
		NSNumber *newPostNumber = [self newPostNumberFromResponse: 
			responseString];
		Post *post = [[[Post alloc] initStubWithPostNumber:
			newPostNumber board: [self boardCode]] autorelease];
		// TODO: - Fully init the post.. image res?
		if (op != nil) {
			[self success: post];
		} else {
			Thread *thread = [[[Thread alloc] initWithPosts: 
				[NSArray arrayWithObject: post]] autorelease];
			[self success: thread];
		}
	} else {
		[self failure: [NSError unexpectedResponseError]];
	}
}

-(NSString*)boardCode {
	NSString *boardCode;
	if (op != nil) {
		boardCode = [op getBoard];
	} else {
		boardCode = board;
	}
	return boardCode;
}

-(NSString*)bodyContentForTextField: (NSString*)field withValue: (NSString*)value {
	return [NSString stringWithFormat: @"--%@\nContent-Disposition: form-data; name=\"%@\"\n\n%@\n", FORM_DELIM, field, value];
}

-(NSString*)filename {
	if (imageURL == nil) { 
		return @"";
	} else {
		return [[imageURL pathComponents] lastObject];
	}
}

-(NSString*)fileMimeType {
	if (imageURL == nil) {
		return @"jpeg";
	} else {
		NSString *ext = [imageURL pathExtension];
		if ([ext isEqualToString: @"jpg"]) {
			return @"image/jpeg";
		} else {
			return [NSString stringWithFormat: @"image/%@", ext];
		}
	}
}

-(NSNumber*)newPostNumberFromResponse: (NSString*)response {
	NSError *error = nil;
	NSString *pattern = @"<meta http-equiv=\"refresh\".+URL=.+?([0-9]+)\".*>";
	NSRegularExpression *regexp = [[NSRegularExpression alloc]
		initWithPattern: pattern
		options: 0
		error: &error
	];
	[regexp autorelease];
	if (error != nil) {
		NSLog(@"error creating regexp: %@", error);
		return nil;
	}
	NSNumber *number = nil;
	NSTextCheckingResult *result = [regexp firstMatchInString: 
		response
		options: 0
		range: NSMakeRange(0, [response length])];
	NSLog(@"Getting range");
	NSRange range = [result rangeAtIndex: 1];
	NSString *string = [response substringWithRange: range];
	number = [NSNumber numberWithInt: [string intValue]];
	NSLog(@"Result number: %@", number);
	return number;
}

@end
