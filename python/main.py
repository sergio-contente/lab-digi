import paho.mqtt.client as mqtt
import time
import datetime

from alphabet_translation import *
import string

# Credenciais da bancada e do laboratório
user = "grupo2-bancadaA3"
passwd = "L@Bdygy2A3"
# Conectar via MQTT (IP da rede do laboratório)
Broker = "labdigi.wiseful.com.br"
Port = 80
KeepAlive = 60

tem_letra = "1"
tem_jogada = "0"
aguardando_publish = False
word_published = False
letter_published = False
first_time = True
iterador_palavra = 0
segue = False
timer = False

palavra = ""
leds = ["0", "0"]

resultados = ""  # <---

jogada_correta = "0"

contagem_letras = 0

led0: str = '0'
led1: str = '0'
recebeu_l1 = False
recebeu_l0 = False

# Quando conectar na rede (Callback de conexao)


def on_connect(client, userdata, flags, rc):
    global resultados
    global contagem_letras

    print("Conectado com codigo " + str(rc))
    client.subscribe(user+"/E1", qos=0)
    for i in range(0, 5):
        client.subscribe(user+"/S" + str(i), qos=0)
    # client.publish(user+"/S0", payload="0", qos=0)
    # time.sleep(0.5)
    # client.publish(user+"/S1", payload="0", qos=0)
    for i in range(0, 8):
        client.publish(user+"/E" + str(i), payload="0", qos=0)
    resultados = ""
    contagem_letras = 0


def publish_letter(letter):
    print(palavra)
    global palavra_ant
    global enable
    global tem_letra
    global tempo
    global iterador_palavra

    enable = 1
    palavra_ant = palavra
    # for letra in palavra:
    #   if aguardando_publish == False:
    client.publish(user+"/RX", payload=letter, qos=0)
    time.sleep(2)
    iterador_palavra += 1
    tempo = 0

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


def pronto_publish():
    global contagem_letras
    global resultados
    global tempo
    global contagem
    global leds
    global aguardando_publish
    global letter_published
    global timer
    global recebeu_l0
    global recebeu_l1

    #print(f'datetime.datetime.now().second - tempo: {datetime.datetime.now().second - tempo}')
    while not letter_published:
        if (contagem == 2 or datetime.datetime.now().second - tempo > 15) and contagem != 0:
            print("\n>>>", datetime.datetime.now().second - tempo, "\n")
            print("Recebi uma cor")
            client.publish(user+"/E" + "3", payload="1", qos=0)
            time.sleep(1)
            client.publish(user+"/E" + "3", payload="0", qos=0)
            time.sleep(1)
            print(f'contagem : {contagem}')
            contagem = 0
            resultados += leds[0] + leds[1]
            contagem_letras += 1
            aguardando_publish = False
            print(f'resultados : {resultados}')
            print(f'contagem_letras : {contagem_letras}')
            letter_published = True
            recebeu_l0 = False
            recebeu_l1 = False
        if timer == True:
            tempo += 1

# Quando receber uma mensagem (Callback de mensagem)


def on_message(client, userdata, msg):
    # print(type(msg.payload.decode("utf-8")))
    global palavra
    global contagem
    global tempo
    global aguardando_publish
    global word_published
    global contagem_letras
    global led0
    global led1
    global recebeu_l0
    global recebeu_l1

    aguardando_publish = True
    tempo = datetime.datetime.now().second
    if word_published == True:
        palavra = str(msg.payload.decode("utf-8"))
        print(str(msg.topic)+" "+str(msg.payload.decode("utf-8")))
        word_published = False

    if str(msg.topic) == user+"/E1":
        print("Recebi uma mensagem de E1")
        word_published = False  
    elif str(msg.topic) == user+"/S0" or str(msg.topic) == user+"/S1":
        print("entrou em if de s0 ou s1")
        print(f"recebeu l0 = {recebeu_l0} e recebeu l1 = {recebeu_l1}")
        if str(msg.topic) == user+"/S0" and (recebeu_l0 == False):
          leds[0] = str(msg.payload.decode("utf-8"))
          print(f"leds[0] = {leds[0]}")
          recebeu_l0 = True
          contagem += 1
        elif str(msg.topic) == user+"/S1" and (recebeu_l1 == False):
          leds[1] = str(msg.payload.decode("utf-8"))
          print(f"leds[1] = {leds[1]}")
          recebeu_l1 = True
          contagem += 1
        print(str(msg.topic) + "   " + str(msg.payload.decode("utf-8")))
        print(f"contagem no callback: {contagem}")
    else:
        print("Erro! Mensagem recebida de tópico estranho")


contagem = 0

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
#client.publish(user+"/S0", payload="0", qos=0, retain=False)
palavra_ant = palavra
time.sleep(1)
while True:
    #print(f'word_published: {word_published}')
    if word_published == False and not first_time:  # palavra_ant != palavra or
        print(f'palavra {palavra}')
        timer = True
        client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
        tem_jogada = "1"
        client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
        letter = palavra[iterador_palavra]
        print(f'letter: {letter}')
        print(f'iterador_palavra: {iterador_palavra}')
        print(f'contagem_letras: {contagem_letras}')
        if iterador_palavra == contagem_letras:
            print(f'publiquei: {iterador_palavra == contagem_letras}')
            publish_letter(letter)
            tem_jogada = "0"
            client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
            letter_published = False
    elif first_time:
        first_time = False
        word_published = True
        letter_published = True
        iterador_palavra = 0
    elif tem_jogada == "1" and contagem_letras == 5:
        tem_jogada = "0"
        client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
        time.sleep(0.00075)
    # if aguardando_publish:
    pronto_publish()

    if contagem_letras == 5:
        print("entrou contagem_letras == 5")
        if resultados == "1111111111":
            jogada_correta = "1"
        else:
            jogada_correta = "0"
        client.publish(user+"/E5", payload=jogada_correta, qos=0, retain=False)
        time.sleep(1)
        jogada_correta = "0"
        client.publish(user+"/E5", payload=jogada_correta, qos=0, retain=False)
        time.sleep(1)
        contagem_letras = 0
        iterador_palavra = 0
        word_published = True
        timer = False
        tem_jogada = "0"
        client.publish(user+"/E0", payload=tem_jogada, qos=0, retain=False)
        resultados = ""  # resetando resultados

client.loop_stop()

client.disconnect()
