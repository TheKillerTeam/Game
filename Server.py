from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from twisted.internet.task import LoopingCall
from time import time
from struct import *

MESSAGE_PLAYER_CONNECTED = 0
MESSAGE_NOT_IN_MATCH = 1
MESSAGE_START_MATCH = 2
MESSAGE_MATCH_STARTED = 3

MATCH_STATE_ACTIVE = 0
MATCH_STATE_GAME_OVER = 1

PLAYER_STATE_ONE = 0

SECS_FOR_SHUTDOWN = 5

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
        
class GameMatch:

    def __init__(self, players):
        self.players = players
        self.state = MATCH_STATE_ACTIVE
	self.pendingShutdown = False
	self.shutdownTime = 0
	self.timer = LoopingCall(self.update)
	self.timer.start(5)

    def __repr__(self):
        return "%d %s" % (self.state, str(self.players))

    def write(self, message):
        message.writeByte(self.state)
        message.writeByte(len(self.players))
        for matchPlayer in self.players:
	    matchPlayer.write(message)
	    
    def update(self):
	print "Match update: %s" % (str(self))
	if (self.pendingShutdown):
	    cancelShutdown = True
	    for player in self.players:
		if player.protocol == None:
		    cancelShutdown  =False
	    if (time() > self.shutdownTime):
		print "Time elapsed, shutting down match"
		self.quit()
	else:
	    for player in self.players:
		if player.protocol == None:
		    print "Player %s disconnected, scheduling shutdown" % (player.alias)
		    self.pendingShutdown = True
		    self.shutdownTime = time() + SECS_FOR_SHUTDOWN
			
    def quit(self):
	self.timer.stop()
	for matchPlayer in self.players:
	    matchPlayer.match = None
	    if matchPlayer.protocol:
		matchPlayer.protocol.sendNotInMatch()    

class GamePlayer:

    def __init__(self, protocol, playerId, alias):
        self.protocol = protocol
        self.playerId = playerId
        self.alias = alias
        self.match = None
        self.playerState = PLAYER_STATE_ONE

    def __repr__(self):
        return "%s:%d" % (self.alias, self.playerState)

    def write(self, message):
        message.writeString(self.playerId)
        message.writeString(self.alias)
        message.writeInt(self.playerState)
        
    def startMatch(self, playerIds):
    	matchPlayers = []
    	for existingPlayer in self.players:
	    if existingPlayer.playerId in playerIds:
    		if existingPlayer.match != None:
		    return
    		matchPlayers.append(existingPlayer)
    	match = GameMatch(matchPlayers)
    	for matchPlayer in matchPlayers:
	    matchPlayer.match = match
	    matchPlayer.protocol.sendMatchStarted(match)

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
        
    def startMatch(self, playerIds):
	matchPlayers = []
	for existingPlayer in self.players:
	    if existingPlayer.playerId in playerIds:
		if existingPlayer.match != None:
		    return
		matchPlayers.append(existingPlayer)
	match = GameMatch(matchPlayers)
	for matchPlayer in matchPlayers:
	    matchPlayer.match = match
	    matchPlayer.protocol.sendMatchStarted(match)

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
		
	def sendMatchStarted(self, match):
	    message = MessageWriter()
	    message.writeByte(MESSAGE_MATCH_STARTED)
	    match.write(message)
	    self.log("Sent MATCH_STARTED %s" % (str(match)))
	    self.sendMessage(message)
	
	def startMatch(self, message):
	    numPlayers = message.readByte()
	    playerIds = []
	    for i in range(0, numPlayers):
		playerId = message.readString()
		playerIds.append(playerId)
	    self.log("Recv MESSAGE_START_MATCH %s" % (str(playerIds)))
	    self.factory.startMatch(playerIds)

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
	    if messageId == MESSAGE_START_MATCH:
		return self.startMatch(message)
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