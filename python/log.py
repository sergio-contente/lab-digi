from openlab import *
time_score = get_time_score()
f = open("score.txt", "a")
f.write(time_score)
f.close()
