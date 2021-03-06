from behavior_gui.setup import ag, status
import behavior_gui.initialStatus
import behavior_gui.callbacks
from behavior_gui.socketApp import socketio, app as sockets
# from behavior_gui.httpServer import app as server
from threading import Thread

if __name__ == "__main__":
  # Thread(target=socketio.run, args=(sockets,), kwargs={'port': 5001}).start()
  # server.run(host='localhost', port=5000, debug=False,
  #            use_reloader=False)
  socketio.run(sockets, port=5001)
