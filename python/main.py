import paho.mqtt.client as mqtt
import numpy as np
import time

from alphabet_translation import *
import string

#Credenciais da bancada e do laboratório
user = "grupo2-bancadaA3"
passwd = "L@Bdygy2A3"
#Conectar via MQTT (IP da rede do laboratório)
Broker = "labdigi.wiseful.com.br"           
Port = 80                           
KeepAlive = 60

tem_letra  = "1"
tem_jogada = "0"
palavra = ""
# Quando conectar na rede (Callback de conexao)
def on_connect(client, userdata, flags, rc):
  print("Conectado com codigo " + str(rc))
  client.subscribe(user+"/E1", qos=0)
  for i in range(0,8):
    client.publish(user+"/E" + str(i), payload = "0", qos=0)

def publish_word(palavra):
  print(palavra)
  global palavra_ant
  global enable
  global tem_letra
  enable = 1
  palavra_ant = palavra
  for letra in palavra:
    client.publish(user+"/RX", payload=letra, qos=0)
    time.sleep(2)
    # print(enable)
    # letra_bin = get_signal(letra)
    # enable_bin = np.binary_repr(enable,3)
    # print(f'letra: {letra}')
    # print(f'letra_bin: {letra_bin}')
    # for i in range(len(letra_bin)):
    #   if i < 3:
    #     client.publish(user+"/S" + str(i+5), payload=enable_bin[len(enable_bin) - i - 1], qos=0, retain=False)
    #   client.publish(user+"/S" + str(i), payload=letra_bin[len(letra_bin) - i - 1], qos=0, retain=False)
    #   time.sleep(0.00025)
    #   client.loop_stop()
    #   client.loop_start()
    # for j in range(len(enable_bin)):
    #   client.publish(user+"/S" + str(j+5), payload=0, qos=0, retain=False)
    #   time.sleep(0.00075)
    # enable += 1


# Quando receber uma mensagem (Callback de mensagem)
def on_message(client, userdata, msg):
  #print(type(msg.payload.decode("utf-8")))
  global palavra
  palavra = str(msg.payload.decode("utf-8"))
  print(str(msg.topic)+" "+str(msg.payload.decode("utf-8")))

  if str(msg.topic) == user+"/E1":
    print("Recebi uma mensagem de E1")
  elif str(msg.topic) == user+"/E1":
    print("Recebi uma mensagem de E1")
  else:
    print("Erro! Mensagem recebida de tópico estranho")

client = mqtt.Client()              
client.on_connect = on_connect      
client.on_message = on_message  

client.username_pw_set(user, passwd)

print("=================================================")
print("Teste Cliente MQTT")
print("=================================================")

client.connect(Broker, Port, KeepAlive)

client.loop_start() 

# A primeira mensagem costuma ser perdida aqui no notebook
client.publish(user+"/S0", payload="0", qos=0, retain=False)
palavra_ant = palavra
time.sleep(1)
while True:
  if palavra_ant != palavra:
    tem_jogada = "1"
    client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
    time.sleep(0.00075) #3/4 de ciclo de clock
    publish_word(palavra)
    tem_jogada = "0"
    client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
    time.sleep(0.00075)
  elif tem_jogada == "1":
    tem_jogada = "0"
    client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
    time.sleep(0.00075)
client.loop_stop()

client.disconnect()
