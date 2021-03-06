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
#import "NSError+AppErrors.h"

@implementation NSError (AppErrors)

+(NSError*)invalidBoardCodeError {
	return [NSError errorWithDomain: AppErrorDomain
		code: AppErrorCodeInvalidBoardCode
		userInfo: nil];
}

+(NSError*)unexpectedResponseError {
	return [NSError errorWithDomain: AppErrorDomain
		code: AppErrorCodeUnexpectedResponse
		userInfo: nil];
}

+(NSError*)otherError {
	return [NSError errorWithDomain: AppErrorDomain
		code: AppErrorCodeOther
		userInfo: nil];
}

+(NSError*)noPassError {
	return [NSError errorWithDomain: AppErrorDomain
		code: AppErrorCodeNoPassID
		userInfo: nil];
}
+(NSError*)invalidPassError {
	return [NSError errorWithDomain: AppErrorDomain
		code: AppErrorCodeInvalidPassID
		userInfo: nil];
}


@end
