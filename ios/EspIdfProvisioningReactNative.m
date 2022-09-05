#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(EspIdfProvisioningReactNative, NSObject)

RCT_EXTERN_METHOD(create)
RCT_EXTERN_METHOD(scanBleDevices:(NSString *)prefix resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(connectToBLEDevice:(NSString *)name resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getProofOfPossession:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setProofOfPossession:(NSString *)proof)
RCT_EXTERN_METHOD(scanNetworks:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(provisionNetwork:(NSString *)ssid password:(NSString *)password resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(sendCustomData:(NSString *)customEndPoint customData:(NSString *)customData resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
