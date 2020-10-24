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
#import "CaptchaImageNetworkSource.h"

static NSString *const USER_AGENT = @"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36";
static NSString *const ACCEPT_ENCODE = @"Accept-Encoding: deflate, br";
static NSString *const ACCEPT_LANG = @"Accept-Language: en-US";
static NSString *const COOKIE = @"NID=87=gkOAkg09AKnvJosKq82kgnDnHj8Om2pLskKhdna02msog8HkdHDlasDf";
static NSString *const ACCEPT = @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3";

@implementation CaptchaImageNetworkSource

-(NSDictionary*)additionalHeaders {
	return [NSDictionary dictionaryWithObjectsAndKeys:
		USER_AGENT, @"User-Agent",
		ACCEPT_ENCODE, @"Accept-Encoding",
		ACCEPT_LANG, @"Accept-Language",
		ACCEPT, @"Accept",
		COOKIE, @"Cookie",
		NULL];
}

@end