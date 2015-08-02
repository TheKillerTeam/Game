from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
 
class GameFactory(Factory):
    def __init__(self):
        self.protocol = GameProtocol
 
class GameProtocol(Protocol):
 
    def log(self, message):
        print message  
 
    def connectionMade(self):
        self.log("Connection made")
 
    def connectionLost(self, reason):
        self.log("Connection lost: %s" % str(reason))
 
factory = GameFactory()
reactor.listenTCP(1955, factory)
print "Game server started"
reactor.run()