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
#import "FrontPageNetworkSource.h"
#import "Data/Thread.h"
#import "Net/NSURL+Utils.h"
#import "NSError+AppErrors.h"

// TODO: - Set code to 'home board' preference in init
static NSString *const DEFAULT_CODE = @"g";

@implementation FrontPageNetworkSource

-(id)init {
	if ((self = [super init])) {
		code = DEFAULT_CODE;
	}
	return self;
}

-(id)initWithCode: (NSString*)aCode {
	if ((self = [super init])) {
		code = aCode;
	}
	return self;
}

-(void)makeSynchronousRequest {
	NSURL *url = [NSURL urlForIndex: [NSNumber numberWithInt: 1] ofBoard: code];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSLog(@"Fetching request: %@", request);
	// TODO: - Dealloc
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	NSMutableArray *threads = [[NSMutableArray alloc] init];
	if (data != nil) {
		NSLog(@"Successfully made request for threads");
		NSDictionary *json = [NSJSONSerialization 
			JSONObjectWithData: data 
			options: 0 
			error: &error];
		NSArray *threadsJson = [json objectForKey: @"threads"];
		if (threadsJson == nil) {
			[self failure: [NSError invalidBoardCodeError]];
			return;
		}
		for (int i = 0; i < [threadsJson count]; i++) {
			Thread *thread = [[Thread alloc] 
				initWithDictionary: [threadsJson objectAtIndex: i]
				onBoard: code];
			[thread autorelease];
			[threads addObject: thread];
		}
		[self success: threads];
		[threads release];
	}
}

@end
