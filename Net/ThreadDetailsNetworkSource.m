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
#import "ThreadDetailsNetworkSource.h"
#import "Data/Thread.h"
#import "Net/NSURL+Utils.h"

@implementation ThreadDetailsNetworkSource

-(id)initWithThread: (Thread*)aThread {
	if ((self = [super init])) {
		thread = aThread;
	}
	return self;
}

-(void)makeSynchronousRequest {
	NSURL *url = [NSURL urlForThreadDetails: thread];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	NSURLResponse *response;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest: request
		returningResponse: &response
		error: &error];
	if (error) {
		[self failure: error];
	}
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data 
			options: 0 
			error: &error];
	if (error) {
		[self failure: error];
	}
	Thread *detailedThread = [[Thread alloc] initWithDictionary: dict];
	[self success: detailedThread];
}

@end
