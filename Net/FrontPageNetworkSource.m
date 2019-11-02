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

@implementation FrontPageNetworkSource

-(void)fetch {
	NSURL *url = [NSURL urlForIndex: [NSNumber numberWithInt: 1] ofBoard: @"g"];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSLog(@"Fetching request: %@", request);
	// TODO: - Dealloc
	NSURLResponse *response = [NSURLResponse alloc];
	NSError *error = [NSError alloc];
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
		for (int i = 0; i < [threadsJson count]; i++) {
			Thread *thread = [[Thread alloc] initWithDictionary: [threadsJson objectAtIndex: i]];
			[thread autorelease];
			[threads addObject: thread];
		}
		NSLog(@"idx 0: %@", [threads firstObject]);
		[successTarget performSelector: successSelector
			onThread: [NSThread mainThread]
			withObject: threads
			waitUntilDone: NO];
	}
}

-(void)performOnSuccess: (SEL)selector target: (id)target {
	successSelector = selector;
	successTarget = target;
}

-(void)performOnFailure: (SEL)selector target: (id)target {
	failureSelector = selector;
	failureTarget = target;
}

-(void)connectionDidFinishLoading: (NSURLConnection*)connection {
	NSLog(@"Finished loading");
}

-(void)connection: (NSURLConnection*)connection didReceiveData: (NSData*)data {
	NSLog(@"Did Receive Data");
}

-(void)connection: (NSURLConnection*)connection didRecieveResponse: (NSURLResponse*)response {
	NSLog(@"Received response %@", response);
}

-(void)connection: (NSURLConnection*)connection didFailWithError: (NSError*)error {
	NSLog(@"Error, %@", error);
}

@end
