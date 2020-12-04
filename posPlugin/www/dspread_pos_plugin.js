
var exec = require('cordova/exec');

var posPlug = {
	  scanQPos2Mode:function(success,fail){
	   exec(success,fail,"dspread_pos_plugin","scanQPos2Mode",[]);
	},
	
	  connectBluetoothDevice:function(success,fail,isConnect,bluetoothAddress){
		  exec(success,fail,"dspread_pos_plugin","connectBluetoothDevice",[isConnect,bluetoothAddress]);
	},

	doTrade:function(success,faill,timeout){
		  exec(success,faill,"dspread_pos_plugin","doTrade",[timeout]);
		},
	
	getDeviceList:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","getDeviceList",[]);
		},
	
	stopScanQPos2Mode:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","stopScanQPos2Mode",[]);
		},
	
	disconnectBT:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","disconnectBT",[]);
		},
               
    updateEMVConfigByXml:function(success,fail){
      exec(success,fail,"dspread_pos_plugin","updateEMVConfigByXml",[]);
    },
	
	getQposInfo:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","getQposInfo",[]);
		},
	
	getQposId:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","getQposId",[]);
		},
	
	updateIPEK:function(success,fail,ipekgroup, trackksn, trackipek, trackipekCheckvalue, emvksn, emvipek, emvipekCheckvalue, pinksn, pinipek, pinipekCheckvalue){
		  exec(success,fail,"dspread_pos_plugin","updateIPEK",[ipekgroup, trackksn, trackipek, trackipekCheckvalue, emvksn, emvipek, emvipekCheckvalue, pinksn, pinipek, pinipekCheckvalue]);
		},
	
	updateEmvApp:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","updateEmvApp",[]);
		},
	
	updateEmvCAPK:function(success,fail){
		  exec(success,fail,"dspread_pos_plugin","updateEmvCAPK",[]);
		},
	
	setMasterKey:function(success,fail,key,checkValue){
		  exec(success,fail,"dspread_pos_plugin","setMasterKey",[key,checkValue]);
		},
	updatePosFirmware:function(success,fail){
		exec(success,fail,"dspread_pos_plugin","updatePosFirmware",[]);
	},

	getIccCardNo:function(success,fail){
		exec(success,fail,"dspread_pos_plugin","getIccCardNo",[]);
	},
	
	setAmount:function(success,fail,amount,cashbackAmount,currencyCode,transactionType){
    	exec(success,fail,"dspread_pos_plugin","setAmount",[amount,cashbackAmount,currencyCode,transactionType]);
    }

	
	};
	module.exports =posPlug;

