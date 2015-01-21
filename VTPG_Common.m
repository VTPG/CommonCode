#import "VTPG_Common.h"
// Copyright (c) 2008-2010, Vincent Gable.
// http://vincentgable.com
//
//based off http://www.dribin.org/dave/blog/archives/2008/09/22/convert_to_nsstring/
//
static BOOL TypeCodeIsCharArray(const char *typeCode){
    size_t len = strlen(typeCode);
    if(len <= 2)
        return NO;
	size_t lastCharOffset = len - 1;
	size_t secondToLastCharOffset = lastCharOffset - 1 ;
	
	BOOL isCharArray = typeCode[0] == '[' &&
						typeCode[secondToLastCharOffset] == 'c' && typeCode[lastCharOffset] == ']';
	for(int i = 1; i < secondToLastCharOffset; i++)
		isCharArray = isCharArray && isdigit(typeCode[i]);
	return isCharArray;
}

//since BOOL is #defined as a signed char, we treat the value as
//a BOOL if it is exactly YES or NO, and a char otherwise.
static NSString* VTPGStringFromBoolOrCharValue(BOOL boolOrCharvalue) {
	if(boolOrCharvalue == YES)
		return @"YES";
	if(boolOrCharvalue == NO)
		return @"NO";
	return [NSString stringWithFormat:@"'%c'", boolOrCharvalue];
}

static NSString *VTPGStringFromFourCharCodeOrUnsignedInt32(FourCharCode fourcc) {
	return [NSString stringWithFormat:@"%u ('%c%c%c%c')",
										fourcc,
										(fourcc >> 24) & 0xFF,
										(fourcc >> 16) & 0xFF,
										(fourcc >> 8) & 0xFF,
										fourcc & 0xFF];
}

static NSString *StringFromNSDecimalWithCurrentLocal(NSDecimal dcm) {
	return NSDecimalString(&dcm, [NSLocale currentLocale]);						   
}

#ifdef __CORELOCATION__
static NSString* StringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
    return [NSString stringWithFormat:@"{latitude=%g,longitude=%g}", coordinate.latitude, coordinate.longitude];
}
#endif

NSString * VTPG_DDToStringFromTypeAndValue(const char * typeCode, void * value) {
	#define IF_TYPE_MATCHES_INTERPRET_WITH(typeToMatch,func) \
		if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
			return (func)(*(typeToMatch*)value)

#if	TARGET_OS_IPHONE
	IF_TYPE_MATCHES_INTERPRET_WITH(CGPoint,NSStringFromCGPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGSize,NSStringFromCGSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGRect,NSStringFromCGRect);
#else
	IF_TYPE_MATCHES_INTERPRET_WITH(NSPoint,NSStringFromPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSSize,NSStringFromSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRect,NSStringFromRect);
#endif
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRange,NSStringFromRange);
	IF_TYPE_MATCHES_INTERPRET_WITH(Class,NSStringFromClass);
	IF_TYPE_MATCHES_INTERPRET_WITH(SEL,NSStringFromSelector);
	IF_TYPE_MATCHES_INTERPRET_WITH(BOOL,VTPGStringFromBoolOrCharValue);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSDecimal,StringFromNSDecimalWithCurrentLocal);
	
	#define IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(typeToMatch,formatString) \
		if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
			return [NSString stringWithFormat:(formatString), (*(typeToMatch*)value)]
	
	
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFStringRef,@"%@"); //CFStringRef is toll-free bridged to NSString*
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFArrayRef,@"%@"); //CFArrayRef is toll-free bridged to NSArray*
	IF_TYPE_MATCHES_INTERPRET_WITH(FourCharCode, VTPGStringFromFourCharCodeOrUnsignedInt32);
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long long,@"%lld");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned long long,@"%llu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(float,@"%f");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(double,@"%f");

#ifdef __CORELOCATION__
    IF_TYPE_MATCHES_INTERPRET_WITH(CLLocationCoordinate2D,StringFromCLLocationCoordinate2D);
#endif

#if __has_feature(objc_arc)
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(__unsafe_unretained id,@"%@");
#else /* not __has_feature(objc_arc) */
    IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(id,@"%@");
#endif
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(short,@"%hi");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned short,@"%hu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(int,@"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned, @"%u");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long,@"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long double,@"%Lf"); //WARNING on older versions of OS X, @encode(long double) == @encode(double)
	
	//C-strings
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(char*, @"%s");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(const char*, @"%s");
	if(TypeCodeIsCharArray(typeCode))
		return [NSString stringWithFormat:@"%s", (char*)value];
	
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(void*,@"(void*)%p");
	
	//we don't know how to convert this typecode into an NSString
	return nil;
}
