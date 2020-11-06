import { Component } from '@angular/core';
import { BluetoothSerial } from '@ionic-native/bluetooth-serial/ngx';
import { AlertController, Platform, ToastController } from '@ionic/angular';

declare let cordova: any;

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})


export class HomePage {

  listMpos: any[] = [];

  cardDetail: any;
  paramPos: any;
  onQposConnected = false; // Conecto MPOS:
  onQposDisconnected = false; // Desconecto MPOS:
  onQposNoDetected = false; // no encontro MPOS:
  onQposBadSwipe = false; // no reconocio la tarjeta swipe MPOS:
  onQposNoCard = false; // no detecto ninguna tarjeta:
  onQposTransaction = false; // Preparar MPOS chip/banda:
  onQposCardInfo = false; // Obtener Card MPOS banda:
  // onRequestDisplay
  onQposTranChipWait = false; // inserto CardChip: please wait..
  onQposTranChipRead = false; // leyendo CardChip: processing...
  onQposTranChipValid = false; // leyendo CardChip: onRequestOnlineProcess:
  onQposTranChipRemove = false; // remover CardChip:remove card
  onQposTranChipCardRemove = false; // Error retiro la tarjeta:card removed
  onQposTranChipCardTerminate = false; // Error retiro la tarjeta:TERMINATED
  onQposTranChipNotICC = false; // Error tarjeta: card_inserted/NOT_ICC
  resChip = false; // respuesta chip
  objectCardData: any = {};

  constructor(private btSerial: BluetoothSerial, private platform: Platform, private toastCtrl: ToastController,
              private alertCtrl: AlertController) {
    console.log('init....');
  }

  scanQPos2Mode(): void{
    console.log('scanQPos2Mode');
    // const txtresult = document.getElementById('posResult');
    const txtresult: HTMLInputElement = document.getElementById('posResult') as HTMLInputElement;
    txtresult.style.display = 'none';
    this.resetStates();

    if (this.platform.is('cordova')) {
      this.btSerial.list().then(data => {
        console.log('Dispositivos: ', data);
        this.listMpos = data;
      }).catch(error => {
        this.posresult(error);
        console.log('Error al listar: ', error);
      });
    } else {
      console.log('estas en web');
    }

    cordova.plugins.dspread_pos_plugin.scanQPos2Mode((success: any) => {
      console.log('termino scan');
      console.log('scanQPos2Mode->success: ' + success);
    }, (fail: any) => {
      console.log('scanQPos2Mode->fail: ' + fail);
      this.posresult(fail);
    }, 30);
  }

  dotrade() {
    console.log('dotrade');
    this.resetStates();

    cordova.plugins.dspread_pos_plugin.doTrade((success: any) => {
      console.log('dotrade->success: ' + success);
      this.posresult(success);
    }, (fail: any) => {
      console.log('dotrade->fail: ' + fail);
      this.posresult(fail);
    }, 30);
  }

  disConnectBT() {
    console.log('disConnectBT');
    cordova.plugins.dspread_pos_plugin.disconnectBT((success: any) => {
      console.log('disConnectBT->success: ' + success);
      this.posresult(success);
    }, (fail: any) => {
      console.log('disConnectBT->fail: ' + fail);
      this.posresult(fail);
    });
  }

  updateEMVConfigureByXml() {
    console.log('updateEMVConfigureByXml');
    cordova.plugins.dspread_pos_plugin.updateEMVConfigByXml();
  }

  connect({name, address}) {
    const mac = `${name} ${address}`;
    console.log('Mac Mpos: ' , mac);
    this.posresult('bluetooth connecting...');
    this.resetStates();

    cordova.plugins.dspread_pos_plugin.connectBluetoothDevice((success: any) => {
      console.log('connectBluetoothDevice->success: ' + success);
      this.posresult(success);
    }, (fail: any) => {
        console.log('connectBluetoothDevice->fail: ' + fail);
        this.posresult(fail);
    }, true, mac);
  }

  posresult(text: string){
    // display the pos status
    const txtresult: HTMLInputElement = document.getElementById('posResult') as HTMLInputElement;
    txtresult.style.display = 'none';
    txtresult.style.display = 'block';
    txtresult.value = text;

    this.getDataQpos(text);
  }

  getDataQpos(data: any) {
    this.paramPos = data;

    if (this.paramPos !== undefined) {
      this.paramPos.startsWith('Swipe') ? this.paramPos = 'getCard' : this.paramPos = data;
      this.paramPos.startsWith('onRequestBatchData:') ? this.paramPos = 'getCardChip' : this.paramPos = data;
    } else {
      console.log('payLoad esta indefinido');
    }

    console.log('*-----------*------------*---------------*');
    console.log('ParamPOS:', this.paramPos);
    console.log('*-----------*------------*---------------*');

    // Validaciones conexion desconexion y swipe
    if (this.paramPos === 'onRequestQposConnected' && !this.onQposConnected) {
      this.onQposConnected = true;
      this.presentToastInfo('Conexión Exitosa');

    } else if (this.paramPos === 'onRequestQposDisconnected' && !this.onQposDisconnected) {
      this.onQposDisconnected = true;
      this.alertInfo('MPOS desconectado', 'Vuelve a conectar el MPOS para cobrar');

    } else if (this.paramPos === 'onRequestNoQposDetected' && !this.onQposNoDetected) {
      this.onQposNoDetected = true;
      this.alertInfo('MPOS desconectado', 'Conecta el MPOS para poder cobrar');

    } else if (this.paramPos === 'please insert/swipe/tap card' && !this.onQposTransaction) {
      this.onQposTransaction = true;
      this.presentToastInfo('MPOS listo para cobrar');

    } else if (this.paramPos === 'bad_swipe' && !this.onQposBadSwipe) {
      this.onQposBadSwipe = true;
      // this.alertInfo('Error Swipe', 'Vuelve a ingresar la tarjeta');
      this.presentToastInfo('No se reconocio la tarjeta, vuelve a intentar');

    } else if (this.paramPos === 'no_card_detected' && !this.onQposNoCard) {
      this.onQposNoCard = true;
      this.alertInfo('Error en Tarjeta', 'No se reconocio la tarjeta, vuelve a ingresarla');

    } else if (this.paramPos.startsWith('Swipe Card:') && !this.onQposCardInfo) {
      this.onQposCardInfo = true;
      this.alertInfo('Tarjeta Aceptada', 'Acepta para realizar el cobro');
      this.parseCard(data);
    }

    // validaciones chip y errores
    else if (this.paramPos === 'card removed' && !this.onQposTranChipCardRemove) {
      this.onQposTranChipCardRemove = true;
      this.alertInfo('Error', 'se retiro la tarjeta, vuelva a intentar');
    } else if (this.paramPos === 'TERMINATED' && !this.onQposTranChipCardTerminate) {
      this.onQposTranChipCardTerminate = true;
      this.alertInfo('Error', 'se retiro la tarjeta, vuelva a intentar');
    } else if (this.paramPos === 'card_inserted/NOT_ICC' && !this.onQposTranChipNotICC) {
      this.onQposTranChipNotICC = true;
      this.alertInfo('Error', 'el ICC de la tarjeta no es valido');
    } else if (this.paramPos === 'please wait..' && !this.onQposTranChipWait) {
      this.onQposTranChipWait = true;
      console.log('leyendo tarjeta');
      this.presentToastInfo('Reconociendo tarjeta...');

    } else if (this.paramPos === 'processing...' && !this.onQposTranChipRead) {
      this.onQposTranChipRead = true;
      console.log('Procesando tarjeta');
      this.presentToastInfo('Procesando tarjeta...');

    } else if (this.paramPos === 'onRequestOnlineProcess:' && !this.onQposTranChipValid) {
      this.onQposTranChipValid = true;
      console.log('validando tarjeta');
      this.presentToastInfo('Validando tarjeta...');
    } else if (this.paramPos === 'remove card' && !this.onQposTranChipRemove) {
      this.onQposTranChipRemove = true;
      console.log('Retira la tarjeta');
      this.presentToastInfo('Puedes retirar la tarjeta');

    } else if (this.paramPos === 'getCardChip' && !this.resChip) {
      this.resChip = true;
      console.log('Respuesta del Chip: ', data);
      this.alertInfo('Tarjeta Aceptada Chip', 'Acepta para realizar el cobro');
      this.parseCardChip(data);
    }

    else {
      console.log('ninguna acción:', data);
      console.log('************************');
      console.log(data);
      console.log('************************');
      console.log('info: ', this.onQposCardInfo);
      console.log('************************');
      console.log('normal: ', this.paramPos.startsWith('Swipe Card:'));
      console.log('************************');
      console.log('swipess: ', this.paramPos.startsWith('Swipe'));
    }
  }

  async presentToastInfo(message: string) {
    const toast = await this.toastCtrl.create({
      message,
      duration: 1000,
      position: 'bottom',
    });

    toast.present();
  }

  async alertInfo(header: string, message: string) {
    const alert = await this.alertCtrl.create({
      header,
      message,
      backdropDismiss: false,
      buttons: [{text: 'Ok', handler: () => {}}]
    });

    await alert.present();
  }

  parseCard(card: any) {
    this.cardDetail = card.split('\n');
    this.cardDetail.forEach((element: any) => {
      const propiedad = element.split(':').shift();
      const valor     = element.substring(element.indexOf(':') + 1);

      this.objectCardData[propiedad] = valor.trim();
    });

    console.log('************ card detail *****************');
    console.log(this.objectCardData);
  }

  parseCardChip(card: any) {
    const prop  = card.split(':').shift();
    const value = card.substring(card.indexOf(':') + 1);
    this.objectCardData[prop] = value.trim();

    console.log('************ card detail chip *****************');
    console.log(this.objectCardData);
  }

  resetStates() {
    this.onQposConnected = false;
    this.onQposDisconnected = false;
    this.onQposNoDetected = false;
    this.onQposBadSwipe = false;
    this.onQposNoCard = false;
    this.onQposTransaction = false;
    this.onQposCardInfo = false;
    this.onQposTranChipNotICC = false;
    this.onQposTranChipWait = false;
    this.onQposTranChipRead = false;
    this.onQposTranChipValid = false;
    this.onQposTranChipRemove = false;
    this.onQposTranChipCardRemove = false;
    this.onQposTranChipCardTerminate = false;
    this.resChip = false;
    this.paramPos = '';
    this.cardDetail = {};
    this.objectCardData = {};
  }

  onReturnCustomConfigResult(str: string){
    this.posresult(str);
  }

}
