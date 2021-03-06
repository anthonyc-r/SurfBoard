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
#import <AppKit/AppKit.h>

static const int NORMAL_FONT_SIZE = 12;
static const int HEADING_FONT_SIZE = 18;

@implementation NSFont (AppFont)

+(NSFont*)appBodyFont {
	return [NSFont systemFontOfSize: NORMAL_FONT_SIZE];
}

+(NSFont*)appBoldBodyFont {
	return [NSFont boldSystemFontOfSize: NORMAL_FONT_SIZE];	
}

+(NSFont*)appHeadingFont {
	return [NSFont systemFontOfSize: HEADING_FONT_SIZE];
}

@end
