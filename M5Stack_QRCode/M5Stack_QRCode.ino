#include <M5Stack.h>
#include <WiFi.h>
#include <WiFiUdp.h>

const char* ssid = "NOME-DA-SUA-REDE";
const char* senha = "SENHA-DA-SUA-REDE";
char qrCode[150];
unsigned int localPort = 8888;

IPAddress ip(192,168,43,12);        
IPAddress gateway(192,168,43,158);  
IPAddress subnet(255,255,255,0);

WiFiUDP conexao;

void setup() {
  M5.begin();
  M5.Power.begin();                 
  M5.Lcd.qrcode("SEU CODIGO GERADO NO DELPHI", 40, 1, 500, 3);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid,senha);
    
  if (!WiFi.config(ip, gateway, subnet)) {
    M5.Lcd.println("Falha ao configurar STA");
  }
  
  while(WiFi.waitForConnectResult() != WL_CONNECTED){
    M5.Lcd.println("Problemas ao conectar!");    
    WiFi.begin(ssid,senha);
    delay(2000);
  }
  
  conexao.begin(localPort);
    
}

void loop() {
  //M5.update();
  
  int tamanhoPacote = conexao.parsePacket();
  if(tamanhoPacote > 0){
    conexao.read(qrCode, tamanhoPacote);
    gerPagamentoPix(qrCode);
  }
  
  conexao.flush();  
}

void gerPagamentoPix(String chave){
  M5.Lcd.clear();
  M5.Lcd.qrcode(chave, 40, 1, 500, 6);  
}
