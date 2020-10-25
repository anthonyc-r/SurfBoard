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

@interface CaptchaChallenge: NSObject {
	NSString *key;
	NSString *instructions;
	NSURL *imageGridURL;
	BOOL selection[9];
}

-(id)initFromHTML: (NSString*)HTML;
-(BOOL)isValid;
-(NSURL*)imageGridURL;
-(NSString*)instructions;
-(NSString*)key;
-(int)imageCount;
-(void)setImageSelected: (BOOL)selected atIndex: (int)index;
-(BOOL)isImageSelectedAtIndex: (int)index;

@end
