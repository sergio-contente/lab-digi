/* AUTOR:     BrincandoComIdeias
*  ACOMPANHE: https://www.youtube.com/brincandocomideias ; https://www.instagram.com/canalbrincandocomideias/
*  APRENDA:   https://cursodearduino.net/ ; https://cursoderobotica.net
*  COMPRE:    https://www.arducore.com.br/
*/
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
String descBotao[6] = {"Jogo da Senha", "Lab Digi", "Jonas", "Arakaki", "Del Llano", "Contente"};
int contador = 0;

void setup() {
  pinMode(pinBackLight, OUTPUT);
  digitalWrite(pinBackLight, HIGH);

  lcd.begin(16, 2);
  Serial.begin(9600);
}

void loop() {
  int valBotoes = analogRead(pinBotoes);

  if ((valBotoes < 800) && (valBotoes >= 600)) {
     estadoBotao(btSELECT);
     
  } else if ((valBotoes < 600) && (valBotoes >= 400)) {
     estadoBotao(btLEFT);
     
  } else if ((valBotoes < 400) && (valBotoes >= 200)) {
     estadoBotao(btUP);
     
  } else if ((valBotoes < 200) && (valBotoes >= 60)) {
     estadoBotao(btDOWN);
     
  } else if  (valBotoes < 60) {
     estadoBotao(btRIGHT);
     
  } else {
     estadoBotao(btNENHUM);
  }
}

void estadoBotao(int botao) {
  //Quando um botao estiver apertado
  if (botao != btNENHUM) {
     Serial.println(botao);
  }

  //Quando o botao for apertado ou solto
  if ((millis() - delayBotao) > tempoDebounce) {
     if ((botao != btNENHUM) && (estadoBotaoAnt == btNENHUM) ) {
        botaoApertado(botao); 
        delayBotao = millis();
     }

     if ((botao == btNENHUM) && (estadoBotaoAnt != btNENHUM) ) {
        botaoSolto(estadoBotaoAnt); 
        delayBotao = millis();
     }
  }
  estadoBotaoAnt = botao;
}

void botaoApertado(int botao) {
  //Quando um bot??o for apertado

  //Para o exemplo de uso
  contador++;
  lcd.clear();
  lcd.print(descBotao[botao]);
  lcd.setCursor(14,0);
  lcd.print(contador);
  lcd.setCursor(0,1);
  lcd.print("AMO LAB DIGI");
}

void botaoSolto(int botao) {
  //Quando um bot??o for solto


  //Para o exemplo de uso
  lcd.clear();
  lcd.print(descBotao[botao]);
  lcd.setCursor(14,0);
  lcd.print(contador);
  lcd.setCursor(0,1);
  lcd.print("SENHA");
}
