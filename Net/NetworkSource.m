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

@implementation NetworkSource

-(void)fetch {
	[self performSelectorInBackground: @selector(makeSynchronousRequest) withObject: nil];
}


-(void)performOnSuccess: (SEL)selector target: (id)target {
	successSelector = selector;
	successTarget = target;
}

-(void)performOnFailure: (SEL)selector target: (id)target {
	failureSelector = selector;
	failureTarget = target;
}

-(void)success: (id)result {
	[successTarget performSelectorOnMainThread: successSelector withObject: result waitUntilDone: YES];
}

-(void)failure: (NSError*)error {
	[failureTarget performSelectorOnMainThread: failureSelector withObject: error waitUntilDone: YES];
}

-(void)makeSynchronousRequest {

}

@end
