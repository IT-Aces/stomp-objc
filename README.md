# stomp-objc
Objective C STOMP over WebSockets

Based on [jetfire](https://github.com/acmacalister/jetfire) and [WebsocketStompKit](https://github.com/rguldener/WebsocketStompKit)

#### Works on iOS12

### Usage:

Init

```
NSURL *websocketUrl = [NSURL URLWithString:@"wss://10.0.0.1"];
self.client = [[STOMPClient alloc] initWithURL:websocketUrl webSocketHeaders:nil useHeartbeat:YES];
```

Connect
```
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
```
Subscribe
```
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
```
