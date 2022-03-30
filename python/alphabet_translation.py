
import string
import numpy as np

def get_signal(letra):
	ord = string.ascii_lowercase.index(letra) - string.ascii_lowercase.index('a') + 1
	payload = np.binary_repr(ord, 5)
	#payload = payload[::-1]
	print("letra: " + letra)
	print("payload: " + payload)
	return payload
