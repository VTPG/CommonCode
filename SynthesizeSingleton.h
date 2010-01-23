//
//  SynthesizeSingleton.h
//
//  Created by Matt Gallagher on 20/10/08.
//
// http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
//
// 2009-01-04: Vincent Gable, vincent.gable@gmail.com , added
// SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_SHARED_INSTANCE_NAME
// for more flexibility defining class names



#define SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_SHARED_INSTANCE_NAME(classname,sharedInstanceName) \
 \
static classname *sharedInstanceName = nil; \
 \
+ (classname *) sharedInstanceName \
{ \
	@synchronized(self) \
	{ \
		if (sharedInstanceName == nil) \
		{ \
			[[self alloc] init]; \
		} \
	} \
	 \
	return sharedInstanceName; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (sharedInstanceName == nil) \
		{ \
			sharedInstanceName = [super allocWithZone:zone]; \
			return sharedInstanceName; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}


#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_SHARED_INSTANCE_NAME(classname, shared##classname)