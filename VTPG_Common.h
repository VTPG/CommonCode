#pragma once
// Copyright (c) 2008-2010, Vincent Gable.
// vincent.gable@gmail.com

//based off of http://www.dribin.org/dave/blog/archives/2008/09/22/convert_to_nsstring/
//an advantage over DDToNString() is that LOG_EXPR()
//does not rely on "statements in expressions"
NSString * VTPG_DDToStringFromTypeAndValue(const char * typeCode, void * value);



// http://vincentgable.com/blog/2008/07/05/fourcharcode2nsstring/
#define FourCharCode2NSString(err)	NSFileTypeForHFSTypeCode(err)


// WARNING: if NO_LOG_MACROS is #define-ed, than THE ARGUMENT WILL NOT BE EVALUATED
#ifndef NO_LOG_MACROS

#define LOG_EXPR(_X_) do{__typeof__(_X_) _Y_ = (_X_);\
NSLog(@"%s = %@", #_X_, VTPG_DDToStringFromTypeAndValue(@encode(__typeof__(_X_)), &_Y_));}while(0);

#define LOG_NS(...) NSLog(__VA_ARGS__)

// http://vgable.com/blog/2008/08/05/simpler-logging-2/
#define LOG_LONG_FLOAT(f) NSLog(@"%s = %Lf", # f, f)

#define LOG_4CC(x)		NSLog(@"%s = %@", # x, FourCharCode2NSString(x))
#define LOG_FUNCTION()	NSLog(@"%s", __FUNCTION__)
#define LOG_ARG_ID(a)	NSLog(@"%s %@", __FUNCTION__, a)
#define LOG_ARG_INT(i)	NSLog(@"%s %i", __FUNCTION__, i)

#else /* NO_LOG_MACROS */

#define LOG_EXPR(_X_)
#define LOG_NS(...)

#define LOG_LONG_FLOAT(f)

#define LOG_4CC(x)
#define LOG_FUNCTION()
#define LOG_ARG_ID(a)
#define LOG_ARG_INT(i)
#endif /* NO_LOG_MACROS */



// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
	return thing == nil ||
			([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
			([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}
