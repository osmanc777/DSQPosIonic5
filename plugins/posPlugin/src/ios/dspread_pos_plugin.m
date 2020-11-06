//
//  dspread_pos_plugin.m
//  qpos-ios-demo
//
//  Created by dspread-mac on 2018/2/1.
//  Copyright © 2018年 Robin. All rights reserved.
//

#import "dspread_pos_plugin.h"
#import "QPOSUtil.h"
#import <AudioToolbox/AudioToolbox.h>
typedef void(^imgBlock)(NSString * data);
@interface dspread_pos_plugin()

@property(nonatomic,strong) imgBlock MyBlock;
@property (nonatomic,copy)NSString *terminalTime;
@property (nonatomic,copy)NSString *currencyCode;
@property(nonatomic,strong)QPOSService *mPos;
@property(nonatomic,strong)BTDeviceFinder *bt;
@property (nonatomic,assign)BOOL updateFWFlag;
@property (nonatomic, strong)CDVInvokedUrlCommand *urlCommand;
@property (nonatomic,strong)CDVPluginResult *pluginResult;
@end


@implementation dspread_pos_plugin
{
    NSMutableArray *allBluetooth;
    NSString *btAddress;
    TransactionType mTransType;
    NSString *amount;
    UIAlertView *mAlertView;
    UIActionSheet *mActionSheet;
    PosType     mPosType;
    dispatch_queue_t self_queue;
    NSString *msgStr;
    NSTimer* appearTimer;

}
@synthesize bluetoothAddress;
@synthesize amount;
@synthesize cashbackAmount;
-(id)init{
    self = [super init];
    if(self != nil){
        [self initPos];
    }
    return self;
}

-(void)scanQPos2Mode:(CDVInvokedUrlCommand *)command{
  [self executeMyMethodWithCommand:command withActionName:@"scanQPos2Mode"];
}

-(void)connectBluetoothDevice:(CDVInvokedUrlCommand *)command{
     [self executeMyMethodWithCommand:command withActionName:@"connectBluetoothDevice"];
}

-(void)disconnectBT:(CDVInvokedUrlCommand *)command{
     [self executeMyMethodWithCommand:command withActionName:@"disconnectBT"];
}

-(void)doTrade:(CDVInvokedUrlCommand *)command{
    [self executeMyMethodWithCommand:command withActionName:@"doTrade"];
}

-(void)stopScanQPos2Mode:(CDVInvokedUrlCommand *)command{
   [self executeMyMethodWithCommand:command withActionName:@"stopScanQPos2Mode"];
}

-(void)getQposInfo:(CDVInvokedUrlCommand *)command{
    [self executeMyMethodWithCommand:command withActionName:@"getQposInfo"];
}

-(void)getQposId:(CDVInvokedUrlCommand *)command{
   [self executeMyMethodWithCommand:command withActionName:@"getQposId"];
}

-(void)updateEMVConfigByXml:(CDVInvokedUrlCommand *)command{
   [self executeMyMethodWithCommand:command withActionName:@"updateEMVConfigByXml"];
}

-(void)updateIPEK:(CDVInvokedUrlCommand *)command{
    [self executeMyMethodWithCommand:command withActionName:@"updateIPEK"];
}
-(void)updateEmvCAPK:(CDVInvokedUrlCommand *)command{
    [self executeMyMethodWithCommand:command withActionName:@"updateEmvCAPK"];
}
-(void)updateEmvApp:(CDVInvokedUrlCommand *)command{
    [self executeMyMethodWithCommand:command withActionName:@"updateEmvApp"];
}
-(void)setMasterKey:(CDVInvokedUrlCommand*)command{
    [self executeMyMethodWithCommand:command withActionName:@"setMasterKey"];
}
    
-(void)updatePosFirmware:(CDVInvokedUrlCommand*)command{
     [self executeMyMethodWithCommand:command withActionName:@"updatePosFirmware"];
}

-(void)initPos{
    if (_mPos == nil) {
        _mPos = [QPOSService sharedInstance];
    }
    [_mPos setDelegate:self];
    [_mPos setQueue:nil];
    [_mPos setPosType:PosType_BLUETOOTH_2mode];
    if (_bt== nil) {
        _bt = [[BTDeviceFinder alloc]init];
    }
    allBluetooth = [[NSMutableArray alloc]init];
}
    
-(void) onQposIdResult: (NSDictionary*)posId{
    NSString *aStr = [@"posId:" stringByAppendingString:posId[@"posId"]];
    
    NSString *temp = [@"psamId:" stringByAppendingString:posId[@"psamId"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [@"merchantId:" stringByAppendingString:posId[@"merchantId"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [@"vendorCode:" stringByAppendingString:posId[@"vendorCode"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [@"deviceNumber:" stringByAppendingString:posId[@"deviceNumber"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    temp = [@"psamNo:" stringByAppendingString:posId[@"psamNo"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:temp];
    
    NSLog(@"posid == %@",aStr);
}

-(void) onQposInfoResult: (NSDictionary*)posInfoData{
    NSLog(@"onQposInfoResult: %@",posInfoData);
    NSString *aStr = @"SUB :";
    aStr = [aStr stringByAppendingString:posInfoData[@"SUB"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:posInfoData[@"bootloaderVersion"]];
    
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Firmware Version: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"firmwareVersion"]];
    
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Hardware Version: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"hardwareVersion"]];
    
    
    NSString *batteryPercentage = posInfoData[@"batteryPercentage"];
    if (batteryPercentage==nil || [@"" isEqualToString:batteryPercentage]) {
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [aStr stringByAppendingString:@"Battery Level: "];
        aStr = [aStr stringByAppendingString:posInfoData[@"batteryLevel"]];
    }else{
        aStr = [aStr stringByAppendingString:@"\n"];
        aStr = [aStr stringByAppendingString:@"Battery Percentage: "];
        aStr = [aStr stringByAppendingString:posInfoData[@"batteryPercentage"]];
    }
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Charge: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"isCharging"]];
    
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"USB: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"isUsbConnected"]];
    
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Track 1 Supported: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack1"]];
    
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Track 2 Supported: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack2"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"Track 3 Supported: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"isSupportedTrack3"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"updateWorkKeyFlag: "];
    aStr = [aStr stringByAppendingString:posInfoData[@"updateWorkKeyFlag"]];
    NSString *posinfo = aStr;
}

-(void)scanBluetooth{
    [self initPos];
    NSInteger delay = 30;
    NSLog(@"蓝牙状态:%ld",(long)[self.bt getCBCentralManagerState]);
    [self.bt setBluetoothDelegate2Mode:self];
    if ([self.bt getCBCentralManagerState] == CBCentralManagerStateUnknown) {
            while ([self.bt getCBCentralManagerState]!= CBCentralManagerStatePoweredOn) {
                NSLog(@"Bluetooth state is not power on");
                [self sleepMs:10];
                if(delay++==10){
                    return;
                }
            }
        }
        [self.bt scanQPos2Mode:delay];
}

-(void) sleepMs: (NSInteger)msec {
    NSTimeInterval sec = (msec / 1000.0f);
    [NSThread sleepForTimeInterval:sec];
}

-(void)onBluetoothName2Mode:(NSString *)bluetoothName{
     if (bluetoothName != nil && ![bluetoothName isEqualToString:@""]) {
           NSLog(@"蓝牙名: %@",bluetoothName);
         if (![allBluetooth containsObject:bluetoothName]) {
             [allBluetooth addObject:bluetoothName];
             [self callbackResult:CDVCommandStatus_OK isKeep:true message:bluetoothName];
         }
       }
}

- (void)callbackResult:(CDVCommandStatus)status isKeep:(BOOL)isKeep message:(NSString *)message{
    self.pluginResult = [CDVPluginResult resultWithStatus:status messageAsString:message];
    [self.pluginResult setKeepCallbackAsBool:isKeep];
    [self.commandDelegate sendPluginResult:self.pluginResult callbackId:self.urlCommand.callbackId];
}
    
-(NSString* )getEMVStr:(NSString *)emvStr{
    NSInteger emvLen = 0;
    if (emvStr != NULL &&![emvStr  isEqual: @""]) {
        if ([emvStr length]%2 != 0) {
            emvStr = [@"0" stringByAppendingString:emvStr];
        }
        emvLen = [emvStr length]/2;
    }else{
        NSLog(@"init emv app config str could not be empty");
        return nil;
    }
    NSData *emvLenData = [QPOSUtil IntToHex:emvLen];
    NSString *totalStr = [[[QPOSUtil byteArray2Hex:emvLenData] substringFromIndex:2] stringByAppendingString:emvStr];
    return totalStr;
}

-(void)doTradeSelf{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    self.terminalTime = [dateFormatter stringFromDate:[NSDate date]];
    mTransType = TransactionType_GOODS;
    _currencyCode = @"156";
    [self.mPos setCardTradeMode:CardTradeMode_SWIPE_TAP_INSERT_CARD];
    [self.mPos doTrade:30];
}

-(void) onRequestSetAmount{
    amount = @"100";
    [self.mPos setAmount:amount aAmountDescribe:@"1000" currency:@"156" transactionType:TransactionType_GOODS];
}

-(void) onRequestWaitingUser{
    NSString *displayStr  =@"Please insert/swipe/tap card now.";
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
}

-(void) onDHError: (DHError)errorState{
    NSString *msg = @"";
    if(errorState ==DHError_TIMEOUT) {
        msg = @"Pos no response";
    } else if(errorState == DHError_DEVICE_RESET) {
        msg = @"Pos reset";
    } else if(errorState == DHError_UNKNOWN) {
        msg = @"Unknown error";
    } else if(errorState == DHError_DEVICE_BUSY) {
        msg = @"Pos Busy";
    } else if(errorState == DHError_INPUT_OUT_OF_RANGE) {
        msg = @"Input out of range.";
    } else if(errorState == DHError_INPUT_INVALID_FORMAT) {
        msg = @"Input invalid format.";
    } else if(errorState == DHError_INPUT_ZERO_VALUES) {
        msg = @"Input are zero values.";
    } else if(errorState == DHError_INPUT_INVALID) {
        msg = @"Input invalid.";
    } else if(errorState == DHError_CASHBACK_NOT_SUPPORTED) {
        msg = @"Cashback not supported.";
    } else if(errorState == DHError_CRC_ERROR) {
        msg = @"CRC Error.";
    } else if(errorState == DHError_COMM_ERROR) {
        msg = @"Communication Error.";
    }else if(errorState == DHError_MAC_ERROR){
        msg = @"MAC Error.";
    }else if(errorState == DHError_CMD_TIMEOUT){
        msg = @"CMD Timeout.";
    }else if(errorState == DHError_AMOUNT_OUT_OF_LIMIT){
        msg = @"Amount out of limit.";
    }
    NSString *error = msg;
    NSLog(@"onError = %@",msg);
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:error];
}

//开始执行start 按钮后返回的结果状态
-(void) onDoTradeResult: (DoTradeResult)result DecodeData:(NSDictionary*)decodeData{
    NSLog(@"onDoTradeResult?>> result %ld",(long)result);
    if (result == DoTradeResult_NONE) {
        NSString *display = @"No card detected. Please insert or swipe card again and press check card.";
         [self callbackResult:CDVCommandStatus_OK isKeep:true message:display];
    }else if (result==DoTradeResult_ICC) {
        NSString *display = @"ICC Card Inserted";
        NSLog(@"%@",display);
        [self.mPos doEmvApp:EmvOption_START];
    }else if(result==DoTradeResult_NOT_ICC){
        NSString *display = @"Card Inserted (Not ICC)";
        NSLog(@"%@",display);
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:display];
    }else if(result==DoTradeResult_MCR){
        NSLog(@"decodeData: %@",decodeData);
        NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
        //NSString *ksn = [NSString stringWithFormat:@"KSN: %@\n",decodeData[@"ksn"]];
        NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
        //NSString *track1Length = [NSString stringWithFormat:@"Track 1 Length: %@\n",decodeData[@"track1Length"]];
        //NSString *track2Length = [NSString stringWithFormat:@"Track 2 Length: %@\n",decodeData[@"track2Length"]];
        //NSString *track3Length = [NSString stringWithFormat:@"Track 3 Length: %@\n",decodeData[@"track3Length"]];
        //NSString *encTracks = [NSString stringWithFormat:@"Encrypted Tracks: %@\n",decodeData[@"encTracks"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
        //NSString *partialTrack = [NSString stringWithFormat:@"Partial Track: %@",decodeData[@"partialTrack"]];
        NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
        NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
        
        NSString *msg = [NSString stringWithFormat:@"Card Swiped:\n"];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        //msg = [msg stringByAppendingString:ksn];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
        NSString *display = msg;
        amount = @"";
        NSString *displayAmount = @"";
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:display];
    }else if(result==DoTradeResult_NFC_OFFLINE || result == DoTradeResult_NFC_ONLINE){
        NSLog(@"decodeData: %@",decodeData);
        NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
        //NSString *ksn = [NSString stringWithFormat:@"KSN: %@\n",decodeData[@"ksn"]];
        NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
        //NSString *track1Length = [NSString stringWithFormat:@"Track 1 Length: %@\n",decodeData[@"track1Length"]];
        //NSString *track2Length = [NSString stringWithFormat:@"Track 2 Length: %@\n",decodeData[@"track2Length"]];
        //NSString *track3Length = [NSString stringWithFormat:@"Track 3 Length: %@\n",decodeData[@"track3Length"]];
        //NSString *encTracks = [NSString stringWithFormat:@"Encrypted Tracks: %@\n",decodeData[@"encTracks"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
        //NSString *partialTrack = [NSString stringWithFormat:@"Partial Track: %@",decodeData[@"partialTrack"]];
        NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
        NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
        
        NSString *msg = [NSString stringWithFormat:@"Tap Card:\n"];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        //msg = [msg stringByAppendingString:ksn];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            NSDictionary *mDic = [self.mPos getNFCBatchData];
            NSString *tlv;
            if(mDic !=nil){
                tlv= [NSString stringWithFormat:@"NFCBatchData: %@",mDic[@"tlv"]];
            }else{
                tlv = @"";
            }
            NSString *displayStr = [msg stringByAppendingString:tlv];
            NSLog(@"%@",displayStr);
            [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
            amount = @"";
        });
        
    }else if(result==DoTradeResult_NFC_DECLINED){
        NSString *displayStr = @"Tap Card Declined";
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
    }else if (result==DoTradeResult_NO_RESPONSE){
        NSString *displayStr = @"Check card no response";
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
    }else if(result==DoTradeResult_BAD_SWIPE){
        NSString *displayStr = @"Bad Swipe. \nPlease swipe again and press check card.";
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
    }else if(result==DoTradeResult_NO_UPDATE_WORK_KEY){
        NSString *displayStr = @"device not update work key";
        [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
    }
}

-(void) onRequestSelectEmvApp: (NSArray*)appList{
    mActionSheet = [[UIActionSheet new] initWithTitle:@"Please select app" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (int i=0 ; i<[appList count] ; i++){
        NSString *emvApp = [appList objectAtIndex:i];
        [mActionSheet addButtonWithTitle:emvApp];
    }
    [mActionSheet addButtonWithTitle:@"Cancel"];
    [mActionSheet setCancelButtonIndex:[appList count]];
    [mActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void) onRequestFinalConfirm{
    NSLog(@"onRequestFinalConfirm-------amount = %@",amount);
    NSString *msg = [NSString stringWithFormat:@"Amount: $%@",amount];
    mAlertView = [[UIAlertView new]
                  initWithTitle:@"Confirm amount"
                  message:msg
                  delegate:self
                  cancelButtonTitle:@"Confirm"
                  otherButtonTitles:@"Cancel",
                  nil ];
    [mAlertView show];
    msgStr = @"Confirm amount";
}

-(void) onRequestTime{
    [self.mPos sendTime:self.terminalTime];
}

-(void) onRequestOnlineProcess: (NSString*) tlv{
    NSLog(@"tlv == %@",tlv);
    NSLog(@"onRequestOnlineProcess = %@",[[QPOSService sharedInstance] anlysEmvIccData:tlv]);
    NSString *msg = @"Replied success.";
    NSString *displayStr = [@"onRequestOnlineProcess: " stringByAppendingString:tlv];
    msgStr = @"Request data to server.";
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
    [self.mPos sendOnlineProcessResult:@"8A023030"];
}

-(void) onRequestTransactionResult: (TransactionResult)transactionResult{
    NSString *messageTextView = @"";
    if (transactionResult==TransactionResult_APPROVED) {
        NSString *message = [NSString stringWithFormat:@"Approved\nAmount: $%@\n",amount];
        if([cashbackAmount isEqualToString:@""]) {
            message = [message stringByAppendingString:@"Cashback: $"];
            message = [message stringByAppendingString:cashbackAmount];
        }
        messageTextView = message;
    }else if(transactionResult == TransactionResult_TERMINATED) {
        messageTextView = @"Terminated";
    } else if(transactionResult == TransactionResult_DECLINED) {
        messageTextView = @"Declined";
    } else if(transactionResult == TransactionResult_CANCEL) {
        messageTextView = @"Cancel";
    } else if(transactionResult == TransactionResult_CAPK_FAIL) {
        messageTextView = @"Fail (CAPK fail)";
    } else if(transactionResult == TransactionResult_NOT_ICC) {
        messageTextView = @"Fail (Not ICC card)";
    } else if(transactionResult == TransactionResult_SELECT_APP_FAIL) {
        messageTextView = @"Fail (App fail)";
    } else if(transactionResult == TransactionResult_DEVICE_ERROR) {
        messageTextView = @"Pos Error";
    } else if(transactionResult == TransactionResult_CARD_NOT_SUPPORTED) {
        messageTextView = @"Card not support";
    } else if(transactionResult == TransactionResult_MISSING_MANDATORY_DATA) {
        messageTextView = @"Missing mandatory data";
    } else if(transactionResult == TransactionResult_CARD_BLOCKED_OR_NO_EMV_APPS) {
        messageTextView = @"Card blocked or no EMV apps";
    } else if(transactionResult == TransactionResult_INVALID_ICC_DATA) {
        messageTextView = @"Invalid ICC data";
    }else if(transactionResult == TransactionResult_NFC_TERMINATED) {
        messageTextView = @"NFC Terminated";
    }
    NSString *displayStr = messageTextView;
    mAlertView = [[UIAlertView new]
                  initWithTitle:@"Transaction Result"
                  message:messageTextView
                  delegate:self
                  cancelButtonTitle:@"Confirm"
                  otherButtonTitles:nil,
                  nil ];
    [mAlertView show];
    self.amount = @"";
    self.cashbackAmount = @"";
    amount = @"";
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
}

-(void) onRequestBatchData: (NSString*)tlv{
    NSLog(@"onBatchData %@",tlv);
    tlv = [@"batch data: " stringByAppendingString:tlv];
    NSString *displayStr = tlv;
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
}

-(void) onReturnReversalData: (NSString*)tlv{
    NSLog(@"onReversalData %@",tlv);
    tlv = [@"reversal data: " stringByAppendingString:tlv];
    NSString *displayStr = tlv;
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
}

//pos 连接成功的回调
-(void) onRequestQposConnected{
    NSLog(@"onRequestQposConnected");
    NSString *displayStr =@"";
    if ([self.bluetoothAddress  isEqual: @"audioType"]) {
        displayStr = @"AudioType connected.";
       
    }else{
        displayStr = @"Bluetooth connected.";
    }
    [self.bt stopQPos2Mode];
    [self callbackResult:CDVCommandStatus_OK isKeep:false message:displayStr];
}

-(void) onRequestQposDisconnected{
    NSLog(@"onRequestQposDisconnected");
    NSString *displayStr = @"pos disconnected.";
    [self callbackResult:CDVCommandStatus_OK isKeep:false message:displayStr];
}

-(void) onRequestNoQposDetected{
    NSLog(@"onRequestNoQposDetected");
    NSString *displayStr = @"No pos detected.";
    [self callbackResult:CDVCommandStatus_ERROR isKeep:false message:displayStr];
}

-(void) onRequestDisplay: (Display)displayMsg{
    NSString *msg = @"";
    if (displayMsg==Display_CLEAR_DISPLAY_MSG) {
        msg = @"";
    }else if(displayMsg==Display_PLEASE_WAIT){
        msg = @"Please wait...";
    }else if(displayMsg==Display_REMOVE_CARD){
        msg = @"Please remove card";
    }else if (displayMsg==Display_TRY_ANOTHER_INTERFACE){
        msg = @"Please try another interface";
    }else if (displayMsg == Display_TRANSACTION_TERMINATED){
        msg = @"Terminated";
    }else if (displayMsg == Display_PIN_OK){
        msg = @"Pin ok";
    }else if (displayMsg == Display_INPUT_PIN_ING){
        msg = @"please input pin on pos";
    }else if (displayMsg == Display_MAG_TO_ICC_TRADE){
        msg = @"please insert chip card on pos";
    }else if (displayMsg == Display_INPUT_OFFLINE_PIN_ONLY){
        msg = @"input offline pin only";
    }else if(displayMsg == Display_CARD_REMOVED){
        msg = @"Card Removed";
    }
    NSString *displayStr = msg;
    [self callbackResult:CDVCommandStatus_OK isKeep:true message:displayStr];
}

-(void) onReturnGetPinResult:(NSDictionary*)decodeData{
    NSString *aStr = @"pinKsn: ";
    aStr = [aStr stringByAppendingString:decodeData[@"pinKsn"]];
    aStr = [aStr stringByAppendingString:@"\n"];
    aStr = [aStr stringByAppendingString:@"pinBlock: "];
    aStr = [aStr stringByAppendingString:decodeData[@"pinBlock"]];
    NSString *displayStr = aStr;
}

-(void) onRequestUpdateWorkKeyResult:(UpdateInformationResult)updateInformationResult{
    NSLog(@"onRequestUpdateWorkKeyResult %ld",(long)updateInformationResult);
    if (updateInformationResult==UpdateInformationResult_UPDATE_SUCCESS) {
        
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_FAIL){
         NSLog(@"Failed");
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_LEN_ERROR){
         NSLog(@"Packet len error");
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_VEFIRY_ERROR){
         NSLog(@"Packer vefiry error");
    }
}

-(void)executeMyMethodWithCommand:(CDVInvokedUrlCommand*)command withActionName:(NSString *)name{
    self.urlCommand = command;
    [self.commandDelegate runInBackground:^{
        if (name != nil) {
            if ([name isEqualToString:@"scanQPos2Mode"]) {
                [self scanBluetooth];
            }else if([name isEqualToString:@"connectBluetoothDevice"]) {
                if (command.arguments.count>0) {
                    NSString* address = command.arguments[1];
                    NSLog(@"address: %@",address);
                    [self.mPos connectBT:address];
                }
            }else if([name isEqualToString:@"doTrade"]) {
                [self doTradeSelf];
            }else if([name isEqualToString:@"getDeviceList"]) {
                [self scanBluetooth];
            }else if([name isEqualToString:@"stopScanQPos2Mode"]) {
                [self.bt stopQPos2Mode];
            }else if ([name isEqualToString:@"disconnectBT"]) {
                [self.mPos disconnectBT];
            }else if ([name isEqualToString:@"getQposInfo"]) {
                [self.mPos getQPosInfo];
            }else if ([name isEqualToString:@"getQposId"]) {
                [self.mPos getQPosId];
            }else if ([name isEqualToString:@"updateEMVConfigByXml"]) {
                [self updateEMVConfigByXML];
            }else if ([name isEqualToString:@"updateIPEK"]) {
                [self updateIpek];
            }else if([name isEqualToString:@"updateEmvApp"]) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            }else if([name isEqualToString:@"updateEmvCAPK"]) {
                
            }else if([name isEqualToString:@"setMasterKey"]){
                [self setMasterKeyTest:0];
            }else if([name isEqualToString:@"updatePosFirmware"]){
                [self updatePosFirmwareTest:nil];
            }
        }else{
            //callback
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"no method found to %@",name]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

//eg: update TMK api in pos.
-(void)setMasterKeyTest:(NSInteger)keyIndex{
    NSString *pik = @"89EEF94D28AA2DC189EEF94D28AA2DC1";//111111111111111111111111
    NSString *pikCheck = @"82E13665B4624DF5";
    pik = @"F679786E2411E3DEF679786E2411E3DE";//33333333333333333333333333333
    pikCheck = @"ADC67D8473BF2F06";
    [self.mPos setMasterKey:pik checkValue:pikCheck keyIndex:keyIndex];
}

-(void) onReturnSetMasterKeyResult: (BOOL)isSuccess{
    if(isSuccess){
         NSLog( @"Success");
    }else{
         NSLog(@"Failed");
    }
}

//update ipek
- (void)updateIpek{
     [self.mPos doUpdateIPEKOperation:@"00" tracksn:@"00000510F462F8400004" trackipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" trackipekCheckValue:@"93906AA157EE2604" emvksn:@"00000510F462F8400004" emvipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" emvipekcheckvalue:@"93906AA157EE2604" pinksn:@"00000510F462F8400004" pinipek:@"293C2D8B1D7ABCF83E665A7C5C6532C9" pinipekcheckValue:@"93906AA157EE2604" block:^(BOOL isSuccess, NSString *stateStr) {
        if (isSuccess) {
            NSLog(@"success: %@",stateStr);
        }
    }];
}

- (void)updateEMVConfigByXML{
    NSLog(@"start update emv configure,pls wait");
    NSData *xmlData = [self readLine:@"emv_profile_tlv"];
    NSLog(@"xmlData; %@",xmlData);
    NSString *xmlStr = [QPOSUtil asciiFormatString:xmlData];
    [self.mPos updateEMVConfigByXml:xmlStr];
}

// callback function of updateEmvConfig and updateEMVConfigByXml api.
-(void)onReturnCustomConfigResult:(BOOL)isSuccess config:(NSString*)resutl{
    if(isSuccess){
        NSLog( @"Success");
    }else{
        NSLog( @"Failed");
    }
    NSLog(@"result: %@",resutl);
}

// update pos firmware api
- (void)updatePosFirmwareTest:(UIButton *)sender {
    NSData *data = [self readLine:@"A27CAYC_S1_master"];//read a14upgrader.asc
    if (data != nil) {
       NSInteger flag = [[QPOSService sharedInstance] updatePosFirmware:data address:self.bluetoothAddress];
        if (flag==-1) {
            NSLog(@"Pos is not plugged in");
            return;
        }
        self.updateFWFlag = true;
        dispatch_async(dispatch_queue_create(0, 0), ^{
            while (true) {
                [NSThread sleepForTimeInterval:0.1];
                NSInteger progress = [self.mPos getUpdateProgress];
                if (progress < 100) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!self.updateFWFlag) {
                            return;
                        }
                        NSLog(@"Current progress:%ld%%",(long)progress);
                    });
                    continue;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"finish upgrader");
                });
                break;
            }
        });
    }else{
        NSLog( @"pls make sure you have passed the right data");
    }
}

// callback function of updatePosFirmware api.
-(void) onUpdatePosFirmwareResult:(UpdateInformationResult)updateInformationResult{
    NSLog(@"%ld",(long)updateInformationResult);
    self.updateFWFlag = false;
    if (updateInformationResult==UpdateInformationResult_UPDATE_SUCCESS) {
        NSLog( @"Success");
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_FAIL){
        NSLog( @"Failed");
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_LEN_ERROR){
        NSLog( @"Packet len error");
    }else if(updateInformationResult==UpdateInformationResult_UPDATE_PACKET_VEFIRY_ERROR){
        NSLog( @"Packer vefiry error");
    }
}

- (NSData*)readLine:(NSString*)name{
    NSString* binFile = [[NSBundle mainBundle]pathForResource:name ofType:@".bin"];
    NSString* ascFile = [[NSBundle mainBundle]pathForResource:name ofType:@".asc"];
    NSString* xmlFile = [[NSBundle mainBundle]pathForResource:name ofType:@".xml"];
    if (binFile!= nil && ![binFile isEqualToString: @""]) {
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data1 = [[NSData alloc] init];
        data1 = [Manager contentsAtPath:binFile];
        return data1;
    }else if (ascFile!= nil && ![ascFile isEqualToString: @""]){
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data2 = [[NSData alloc] init];
        data2 = [Manager contentsAtPath:ascFile];
        //NSLog(@"----------");
        return data2;
    }else if (xmlFile!= nil && ![xmlFile isEqualToString: @""]){
        NSFileManager* Manager = [NSFileManager defaultManager];
        NSData* data2 = [[NSData alloc] init];
        data2 = [Manager contentsAtPath:xmlFile];
        return data2;
    }
    return nil;
}
@end
