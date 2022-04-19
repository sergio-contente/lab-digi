#include <ESP8266WiFi.h>
#include <PubSubClient.h>

String position_letter[3];
String state_letter[2];

String user = "grupo2-bancadaA3";
String passwd = "L@Bdygy2A3";

const char* ssid = "zelda";
const char* password = "contente";
const char* mqtt_server = "labdigi.wiseful.com.br";

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE  (50)
char msg[MSG_BUFFER_SIZE];

int value = 0; //sinal de heartbeat

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
    l
    for(int i = 0; i < length; i ++)
  {
    Serial.print(char(payload[i]));
  
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

}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    
    Serial.print("Attempting MQTT connection...");
    
    // Create a random client ID
    String clientId = user;
    clientId += String(random(0xffff), HEX);
    
    // Attempt to connect
    if (client.connect(clientId.c_str(), user.c_str(), passwd.c_str())) {
      
      Serial.println("connected");
      // Once connected, publish an announcement...

      client.subscribe((user+"/RX")).c_str()); //palavra

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
  Serial.begin(115200);
  
  setup_wifi();
  
  client.setServer(mqtt_server, 80);
  client.setCallback(callback);

  Serial.begin(9600);
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}
