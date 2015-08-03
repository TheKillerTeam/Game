from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from struct import *

MESSAGE_PLAYER_CONNECTED = 0
MESSAGE_NOT_IN_MATCH = 1

class MessageReader:

    def __init__(self, data):
        self.data = data
        self.offset = 0
        
    def readByte(self):
        retval = unpack('!B', self.data[self.offset:self.offset+1])[0]
        self.offset = self.offset + 1
        return retval
        
    def readInt(self):
        retval = unpack('!I', self.data[self.offset:self.offset+4])[0]
        self.offset = self.offset + 4
        return retval

    def readString(self):
        strLength = self.readInt()
        unpackStr = '!%ds' % (strLength)
        retval = unpack(unpackStr, self.data[self.offset:self.offset+strLength])[0]
        self.offset = self.offset + strLength
        return retval

class MessageWriter:

    def __init__(self):
        self.data = ""

    def writeByte(self, value):        
        self.data = self.data + pack('!B', value)

    def writeInt(self, value):
        self.data = self.data + pack('!I', value)

    def writeString(self, value):
        self.writeInt(len(value))
        packStr = '!%ds' % (len(value))
        self.data = self.data + pack(packStr, value)

class GamePlayer:

    def __init__(self, protocol, playerId, alias):
        self.protocol = protocol
        self.playerId = playerId
        self.alias = alias
        self.match = None
        self.playerState = 25

    def __repr__(self):
        return "%s:%d" % (self.alias, self.playerState)

    def write(self, message):
        message.writeString(self.playerId)
        message.writeString(self.alias)
        message.writeInt(self.playerState)

class GameFactory(Factory):

    def __init__(self):
        self.protocol = GameProtocol
        self.players = []

    def connectionLost(self, protocol):
        for existingPlayer in self.players:
            if existingPlayer.protocol == protocol:
                existingPlayer.protocol = None

    def playerConnected(self, protocol, playerId, alias, continueMatch):
        for existingPlayer in self.players:
            if existingPlayer.playerId == playerId:
                existingPlayer.protocol = protocol
                protocol.player = existingPlayer
                if (existingPlayer.match):
                    print "TODO: Already in match case"
                else:
                    existingPlayer.protocol.sendNotInMatch()
                return
        newPlayer = GamePlayer(protocol, playerId, alias)
        protocol.player = newPlayer
        self.players.append(newPlayer)
        newPlayer.protocol.sendNotInMatch()

class GameProtocol(Protocol):

    def __init__(self):
        self.inBuffer = ""
        self.player = None

    def log(self, message):
        if (self.player):
            print "%s: %s" % (self.player.alias, message)
        else:
            print "%s: %s" % (self, message) 

    def connectionMade(self):
        self.log("Connection made")

    def connectionLost(self, reason):
        self.log("Connection lost: %s" % str(reason))
        self.factory.connectionLost(self)

    def sendMessage(self, message):
        msgLen = pack('!I', len(message.data))
        self.transport.write(msgLen)
        self.transport.write(message.data)

    def sendNotInMatch(self):
        message = MessageWriter()
        message.writeByte(MESSAGE_NOT_IN_MATCH)
        self.log("Sent MESSAGE_NOT_IN_MATCH")
        self.sendMessage(message)

    def playerConnected(self, message):
        playerId = message.readString()
        alias = message.readString()
        continueMatch = message.readByte()
        self.log("Recv MESSAGE_PLAYER_CONNECTED %s %s %d" % (playerId, alias, continueMatch))
        self.factory.playerConnected(self, playerId, alias, continueMatch)

    def processMessage(self, message):
        messageId = message.readByte()

        if messageId == MESSAGE_PLAYER_CONNECTED:
        	return self.playerConnected(message)

        self.log("Unexpected message: %d" % (messageId))

    def dataReceived(self, data):
        self.inBuffer = self.inBuffer + data

        while(True):
            if (len(self.inBuffer) < 4):
                return;

            msgLen = unpack('!I', self.inBuffer[:4])[0]
            if (len(self.inBuffer) < msgLen):
                return;

            messageString = self.inBuffer[4:msgLen+4]
            self.inBuffer = self.inBuffer[msgLen+4:]

            message = MessageReader(messageString)
            self.processMessage(message)

factory = GameFactory()
reactor.listenTCP(1955, factory)
print "Game server started"
reactor.run()