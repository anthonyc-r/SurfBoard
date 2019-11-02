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
#import <Data/Thread.h>

@interface FrontPageNetworkSource: NSObject<NSURLConnectionDelegate> {
@private
	id successTarget;
	SEL successSelector;
	id failureTarget;
	SEL failureSelector;
	NSURLConnection *activeConnection;
}

-(void)fetch;
-(void)performOnSuccess: (SEL)selector target: (id)target;
-(void)performOnFailure: (SEL)selector target: (id)target;

@end
