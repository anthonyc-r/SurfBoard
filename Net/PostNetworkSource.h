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
#import "Data/Post.h"


@interface PostNetworkSource: NetworkSource {
	NSString *name;
	NSString *password;
	NSString *subject;
	NSString *comment;
	NSString *board;
	NSString *options;
	NSString *captchaId;
	NSString *captchaChallenge;
	NSString *passId;
	NSURL *imageURL;
	Post *op;
}

-(id)initForOP: (Post*)anOP withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions imageURL: (NSURL*)anImageURL;
-(id)initForBoard: (NSString*)aBoard withName: (NSString*)aName password: (NSString*)aPassword subject: (NSString*)aSubject comment: (NSString*)aComment options: (NSString*)someOptions imageURL: (NSURL*)anImageURL;
-(NSString*)boardCode;
-(void)setPassId: (NSString*)aPassId;
-(void)setCaptchaId: (NSString*)aCaptchaId forChallenge: (NSString*)aCaptchaChallenge;
@end
