//----------------------------------------//

#import <Foundation/Foundation.h>

//----------------------------------------//

NS_ASSUME_NONNULL_BEGIN

@interface ACComManager : NSObject

+ (ACComManager *)sharedManager;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (void)connectWithCompletion:(void(^)(BOOL succeeded))completion;
- (void)subscribeToTopic:(NSString *)topic messageHandler:(void(^)(NSString *message))messageHandler;

@end

NS_ASSUME_NONNULL_END

//----------------------------------------//
