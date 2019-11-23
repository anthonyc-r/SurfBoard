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

@implementation PassNetworkSource

-initWithToken: (NSString*)aToken pin: (NSString*)aPin {
	if ((self = [super init])) {
		token = aToken;
		pin = aPin;
	}
	return self;
}


-(void)makeSynchronousRequest {
	NSString *body = [NSString stringWithFormat: @"act=do_login&id=%@&pin=%@", token, pin];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL urlForPassAuth]];
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: 
		[body dataUsingEncoding: NSASCIIStringEncoding]];
	
}

@end
