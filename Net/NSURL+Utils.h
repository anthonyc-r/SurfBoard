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
#import "Data/Post.h"
#import "Data/Thread.h"

@interface NSURL (Utils)

+(NSURL*)urlForPostImage: (Post*)post;
+(NSURL*)urlForThumbnail: (Post*)post;
+(NSURL*)urlForIndex: (NSNumber*)index ofBoard: (NSString*)board;
+(NSURL*)urlForThreadDetails: (Thread*)thread;
+(NSURL*)urlForFullPostImage: (Post*)post;
+(NSURL*)urlForPassAuth;
+(NSURL*)urlForPostingToBoard: (NSString*)board;
+(NSURL*)urlForCaptchaChallenge;
@end
