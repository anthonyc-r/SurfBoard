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
#import "AppUserDefaults.h"

static NSString *const PASS_ID_KEY = @"pass_id";
static NSString *const USER_NAME_KEY = @"user_name";

@implementation AppUserDefaults

+(NSString*)passID {
	return [[NSUserDefaults standardUserDefaults] 
		objectForKey: PASS_ID_KEY];
}
+(void)setPassID: (NSString*)passID {
	[[NSUserDefaults standardUserDefaults] setObject: passID
		forKey: PASS_ID_KEY];
}

+(NSString*)userName {
	return [[NSUserDefaults standardUserDefaults] 
		objectForKey: USER_NAME_KEY];
}
+(void)setUserName: (NSString*)userName {
	[[NSUserDefaults standardUserDefaults] setObject: userName
		forKey: USER_NAME_KEY];
}

@end
