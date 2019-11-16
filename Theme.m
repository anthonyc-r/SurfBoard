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

#import <AppKit/AppKit.h>
#import "Theme.h"

@implementation Theme

+(NSColor*)postBackgroundColor {
	return [NSColor colorWithDeviceRed: 0.9 green: 0.9 blue: 0.9 alpha: 0.9];
}

+(NSColor*)mainBackgroundColor {
	return [NSColor grayColor];
}

+(NSColor*)postBodyColor {
	return [NSColor blackColor];
}

+(NSColor*)postBackgroundHighlightColor {
	return [NSColor colorWithDeviceRed: 0.85 green: 0.85 blue: 0.85 alpha: 0.9];
}

+(NSColor*)postBodyQuoteColor {
	return [NSColor colorWithDeviceRed: 0.3 green: 0.65 blue: 0.07 alpha: 1.0];
}

+(NSColor*)postSubjectColor {
	return [NSColor colorWithDeviceRed: 0.05 green: 0.05 
		blue: 0.4 alpha: 1.0];
}

+(NSColor*)postNameColor {
	return [NSColor colorWithDeviceRed: 0.05 green: 0.5 
		blue: 0.2 alpha: 1.0];
}

@end
