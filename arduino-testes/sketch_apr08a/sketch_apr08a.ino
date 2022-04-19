#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <LiquidCrystal.h>

//******* CONFIGURACAO DO PROJETO *********
#define pinBotoes A0

#define pinRs 8
#define pinEn 9
#define pinD4 4
#define pinD5 5
#define pinD6 6
#define pinD7 7
#define pinBackLight 10
//*****************************************

#define btNENHUM 0
#define btSELECT 1
#define btLEFT   2
#define btUP     3
#define btDOWN   4
#define btRIGHT  5

#define tempoDebounce 50

unsigned long delayBotao;
int estadoBotaoAnt = btNENHUM;

void estadoBotao(int botao);
void botaoApertado(int botao);
void botaoSolto(int botao);

LiquidCrystal lcd(pinRs, pinEn, pinD4, pinD5, pinD6, pinD7);

//Para o exemplo de uso
String descBotao[5] = {"Jogo da Senha", "Lab Digi", "E", "A", "L"};

String position_letter[3];
String state_letter[2];

String user = "grupo2-bancadaA3";
String passwd = "L@Bdygy2A3";

const char* ssid = "Zelda";
const char* password = "contente";
const char* mqtt_server = "labdigi.wiseful.com.br";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE  (50)
char msg[MSG_BUFFER_SIZE];

int value = 0; //sinal de heartbeat

// bool prevBtn1 = 0; //estado anterior do botão
// bool btn1 = 0; //estado atual do botão

// bool prevBtn2 = 0; //estado anterior do botão
// bool btn2 = 0; //estado atual do botão

// bool prevBtn3 = 0; //estado anterior do botão
// bool btn3 = 0; //estado atual do botão

// bool prevBtn4 = 0; //estado anterior do botão
// bool btn4 = 0; //estado atual do botão

bool led = 0; //estado do led

uint32_t prev_millis;
uint32_t ms_cnt = 0;

const char* zero_cstr = "0";
const char* one_cstr = "1";

int valor;

void setup_wifi() {

  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

// bool prevBtn2 = 0; //estado anterior do botão
// bool btn2 = 0; //estado atual do botão

// bool prevBtn3 = 0; //estado anterior do botão
// bool btn3 = 0; //estado atual do botão

// bool prevBtn4 = 0; //estado anterior do botão
// bool btn4 = 0; //estado atual do botão

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  // Led buit-in mapeado no topico "user/ledhome"
  if (strcmp(topic,(user+"/RX").c_str())==0) {
    lcd.clear();
    for(int i = 0; i < length; i ++)
  {
    Serial.print(char(payload[i]));
    lcd.write(payload[i]);
    lcd.setCursor(i, 1);
  }
  }

  if (strcmp(topic,(user+"/E0").c_str())==0) {
    position_letter[0] = (char)payload[0];
  }

  if (strcmp(topic,(user+"/E1").c_str())==0) {
    position_letter[1] = (char)payload[1];
  }

  if (strcmp(topic,(user+"/E2").c_str())==0) {
    position_letter[2] = (char)payload[2];
  }
  if (strcmp(topic,(user+"/E3").c_str())==0) {
    state_letter[3] = (char)payload[3];
  }
  if (strcmp(topic,(user+"/E3").c_str())==0) {
    state_letter[4] = (char)payload[4];
  }

  // if (strcmp(topic,(user+"/S1").c_str())==0) {
  //   if ((char)payload[0] == '1') {
  //     // tone(D5, NOTE_C4, 250); //125 ou 250
  //   }
  // }

  // if (strcmp(topic,(user+"/S2").c_str())==0) {
  //   if ((char)payload[0] == '1') {
  //     // tone(D5, NOTE_DS5, 250); //125 ou 250
  //   }
  // }

  // if (strcmp(topic,(user+"/S3").c_str())==0) {
  //   if ((char)payload[0] == '1') {
  //     // tone(D5, NOTE_A7, 250); //125 ou 250
  //   }
  // }

}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    
    Serial.print("Attempting MQTT connection...");
    lcd.clear();
    lcd.print(descBotao[0]);

    // Create a random client ID
    String clientId = user;
    clientId += String(random(0xffff), HEX);
    
    // Attempt to connect
    if (client.connect(clientId.c_str(), user.c_str(), passwd.c_str())) {
      
      Serial.println("connected");
      lcd.setCursor(0,1);
      lcd.print(descBotao[1]);
      // Once connected, publish an announcement...

      client.subscribe((user+"/RX").c_str()); //palavra

      client.subscribe((user+"/S0").c_str()); //LCD(0)
      client.subscribe((user+"/S1").c_str()); //LCD(1)
      client.subscribe((user+"/S2").c_str()); //LCD(2)
      client.subscribe((user+"/S3").c_str()); //LCD(3)
      client.subscribe((user+"/S4").c_str()); //LCD(4)
      
    } else {
      
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      
      // Wait 5 seconds before retrying
      delay(5000);
      
    }
  }
}

void setup() {
  pinMode(BUILTIN_LED, OUTPUT);
  pinMode(D5, OUTPUT);

  pinMode(D1, INPUT); //botão como input
  // pinMode(D2, INPUT); //botão como input
  // pinMode(D6, INPUT); //botão como input
  // pinMode(D7, INPUT); //botão como input
  
  Serial.begin(115200);
  
  setup_wifi();
  
  client.setServer(mqtt_server, 80);
  client.setCallback(callback);

  pinMode(pinBackLight, OUTPUT);
  digitalWrite(pinBackLight, HIGH);

  lcd.begin(16, 2);
  Serial.begin(9600);
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  client.publish((user+"/E4").c_str(), one_cstr); // botão virtual
  delay(1000);
  client.publish((user+"/E4").c_str(), zero_cstr); // botão virtual
  delay(1000);


  // if(prev_millis!=millis()){
  //   prev_millis=millis();
  //   if(ms_cnt%100==0){
      
  //     btn1 = digitalRead(D1); //leitura do estado do botão
  //     if (!prevBtn1 and btn1){
  //       Serial.println("botão 1 pressionado (borda de subida)");
  //       client.publish((user+"/E3").c_str(), one_cstr); // botão virtual
  //     }
  //     prevBtn1 = btn1;

  //     btn2 = digitalRead(D2); //leitura do estado do botão
  //     if (!prevBtn2 and btn2){
  //       Serial.println("botão 2 pressionado (borda de subida)");
  //       client.publish((user+"/E4").c_str(), one_cstr); // botão virtual
  //     }
  //     prevBtn2 = btn2;

  //     btn3 = digitalRead(D6); //leitura do estado do botão
  //     if (!prevBtn3 and btn3){
  //       Serial.println("botão 3 pressionado (borda de subida)");
  //       client.publish((user+"/E5").c_str(), one_cstr); // botão virtual
  //     }
  //     prevBtn3 = btn3;

  //     btn4 = digitalRead(D7); //leitura do estado do botão
  //     if (!prevBtn4 and btn4){
  //       Serial.println("botão 4 pressionado (borda de subida)");
  //       client.publish((user+"/E6").c_str(), one_cstr); // botão virtual
  //     }
  //     prevBtn4 = btn4;
      
  //   }
  //   ms_cnt++;
  // }

  // unsigned long now = millis();
  // if (now - lastMsg > 2000) {
  //   lastMsg = now;
  //   ++value;
  //   snprintf (msg, MSG_BUFFER_SIZE, "#%ld", value);
  //   Serial.print("Publish message: ");
  //   Serial.println(msg);
  //   client.publish((user+"/homehello").c_str(), msg);

  //   client.publish((user+"/E3").c_str(), zero_cstr); // botão virtual
  //   client.publish((user+"/E4").c_str(), zero_cstr); // botão virtual
  //   client.publish((user+"/E5").c_str(), zero_cstr); // botão virtual
  //   client.publish((user+"/E6").c_str(), zero_cstr); // botão virtual
  // }
}
