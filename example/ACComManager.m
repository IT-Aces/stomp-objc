//----------------------------------------//

#import "ACComManager.h"

//----------------------------------------//

#import "ACModelUser.h"

//----------------------------------------//

#import "WebsocketStompKit.h"

//----------------------------------------//

@interface ACComManager ()

@property (nonatomic, strong) STOMPClient *client;
@property (nonatomic) BOOL needToReconnect;

@end

//----------------------------------------//

@implementation ACComManager

#pragma mark - Singleton

+ (ACComManager *)sharedManager {
    static ACComManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Overrided methods

- (instancetype)init {
    if (self = [super init]) {
        self.needToReconnect = YES;
        
        NSURL *websocketUrl = [NSURL URLWithString:@"wss://10.0.0.1"];
        self.client = [[STOMPClient alloc] initWithURL:websocketUrl webSocketHeaders:nil useHeartbeat:YES];
        
        if (self.needToReconnect) {
            [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (!self.isConnected) {
                    [self connectWithCompletion:^(BOOL succeeded) {}];
                }
            }];
        }
    }
    
    return self;
}

#pragma mark - Public getters

- (BOOL)isConnected {
    return self.client.connected;
}

#pragma mark - Public methods

- (void)connectWithCompletion:(void(^)(BOOL succeeded))completion {
    if (self.client && !self.client.connected) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self.client connectWithLogin:nil
                                 passcode:nil
                        completionHandler:^(STOMPFrame *_, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                if (completion) completion(error == nil);
                            });
                            
                            if (error) {
                                NSLog(@"%@", error);
                                return;
                            }
                        }];
        });
    }
}

- (void)subscribeToTopic:(NSString *)topic messageHandler:(void(^)(NSString *message))messageHandler {
    if (topic && topic.length > 0 &&
        self.client && self.client.connected) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self.client subscribeTo:topic
                      messageHandler:^(STOMPMessage *message) {
                          if (message && messageHandler) {
                              dispatch_async(dispatch_get_main_queue(), ^(void){
                                  messageHandler([NSString stringWithFormat:@"%@", message]);
                              });
                          }
                      }];
        });
    }
}

@end

//----------------------------------------//

