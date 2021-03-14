extends Node
class_name Twic


signal twitch_connected

signal twitch_disconnected

signal twitch_unavailable

signal twitch_reconnect

signal login_attempt(success)

signal chat_message(sendeeData, Message, Channel)

signal whisper_message(sendeeData, Message, Channel)

signal unhandled_message(Message, Tags)

signal cmdInvalidArgcount(cmdName, sendeeData, cmdData, ArgAry)

signal cmd_no_permission(cmdName, sendeeData, cmdData, ArgAry)

signal pong



export(Array, String) var CommandPrefixes : Array = ["!"]

export(float) var ChatTimeout = 0.5

export(bool) var GetImages : bool = false

export(bool) var DiskCache : bool = false

export(String, FILE) var CachePath = "user://gift/cache"

var websocket : WebSocketClient = WebSocketClient.new()

var user_regex = RegEx.new()

var Restarting

var ChatQueue = []

onready var ChatAccu = ChatTimeout

var channels : Dictionary = {}

var commands : Dictionary = {}

var imageCache : Image_Cache

onready var Time = get_node("/root/Control/SporeTimer/")

enum PermissionsRequired {
	
	Everyone = 0,
	
	VIP = 1,
	
	Sub = 2,
	
	Mod = 4,
	
	Streamer = 8
	
	ModStreamer = 12
	
	NonRegular = 15
}

enum WhereFlag {
	
	Chat = 1
	
	Whisper = 2
}

func _init():
	websocket.verify_ssl = true
	
	user_regex.compile("(?<=!)[\\w]*(?=@)")


func _ready() -> void:
	
	websocket.connect("data_received", self, "data_received")
	
	websocket.connect("connection_established", self, "connection_established")
	
	websocket.connect("connection_closed", self, "connection_closed")
	
	websocket.connect("server_close_request", self, "server_close_request")
	
	websocket.connect("connection_error", self, "connection_error")
	
	if(GetImages):
		
		imageCache = Image_Cache.new(DiskCache, CachePath)
		
		add_child(imageCache)


func connect_to_twitch() -> void:
	
	if(websocket.connect_to_url("wss://irc-ws.chat.twitch.tv:443") != OK):
		
		print_debug("Could not connect to Twitch.")
		
		emit_signal("program_unavailable")


func _process(delta : float) -> void:
	
	if(websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		
		websocket.poll()
		
		if(!ChatQueue.empty() && ChatAccu >= ChatTimeout):
			
			Send(ChatQueue.pop_front())
			
			ChatAccu = 0
			
		else:
			
			ChatAccu += delta


func AuthenticateOauth(Nick : String, Token : String) -> void:
	
	websocket.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	
	Send("PASS " + ("" if Token.begins_with("oauth:") else "oauth:") + Token, true)
	
	Send("NICK " + Nick.to_lower())
	
	RequestCaps()


func RequestCaps(caps : String = "twitch.tv/commands twitch.tv/tags twitch.tv/membership") -> void:
	
	Send("CAP REQ :" + caps)


func Send(Text : String, Token : bool = false) -> void:
	
	websocket.get_peer(1).put_packet(Text.to_utf8())
	
	if(OS.is_debug_build()):
		
		if(!Token):
			
			print("< " + Text.strip_edges(false))
			
		else:
			
			print("< PASS oauth:******************************")


func Chat(Message : String, channel : String = ""):
	
	var Keys : Array = channels.keys()
	
	if(channel != ""):
		
		ChatQueue.append("PRIVMSG " + ("" if channel.begins_with("#") else "#") + channel + " :" + Message + "\r\n")
		
	elif(Keys.size() == 1):
		
		ChatQueue.append("PRIVMSG #" + channels.keys()[0] + " :" + Message + "\r\n")

	else:

		print_debug("No channel specified.")


func Whisper(Message : String, target : String):

	Chat("/w " + target + " " + Message)

func data_received() -> void:

	var Messages : PoolStringArray = websocket.get_peer(1).get_packet().get_string_from_utf8().strip_edges(false).split("\r\n")

	var Tags = {}
	
	for Message in Messages:

		if(Message.begins_with("@")):

			var msg : PoolStringArray = Message.split(" ", false, 1)

			Message = msg[1]

			for Tag in msg[0].split(";"):

				var Pair = Tag.split("=")

				Tags[Pair[0]] = Pair[1]

		if(OS.is_debug_build()):

			print("> " + Message)

		HandleMessage(Message, Tags)


func AddCommand(cmdName : String, Instance : Object, InstanceFunc : String, MaxArgs : int = 0, MinArgs : int = 0, PermissionLevel : int = PermissionsRequired.Everyone, Where : int = WhereFlag.Chat) -> void:

	var FuncRf = FuncRef.new()
	
	var SporeNum = Time.SporeNum

	FuncRf.set_instance(Instance)

	FuncRf.set_function(InstanceFunc)

	commands[cmdName] = Command_Data.new(FuncRf, SporeNum, PermissionLevel, MaxArgs, MinArgs, Where)


func RemoveCommand(cmdName : String) -> void:
	
	commands.erase(cmdName)


func PurgeCommand(cmdName : String) -> void:

	var ToRemove = commands.get(cmdName)

	if(ToRemove):

		var RemoveQueue = []

		for command in commands.keys():

			if(commands[command].func_ref == ToRemove.func_ref):

				RemoveQueue.append(command)

		for queued in RemoveQueue:

			commands.erase(queued)


func AddAlias(cmdName : String, Alias : String) -> void:

	if(commands.has(cmdName)):

		commands[Alias] = commands.get(cmdName)


func AddAliases(cmdName : String, Aliases : PoolStringArray) -> void:

	for Alias in Aliases:

		AddAlias(cmdName, Alias)


func HandleMessage(Message : String, Tags : Dictionary) -> void:
	
	if(Message == ":tmi.twitch.tv NOTICE * :Login authentication failed"):
		
		print_debug("Authentication failed.")
		
		emit_signal("login_attempt", false)
		
		return
		
	if(Message == "PING :tmi.twitch.tv"):
		
		Send("PONG :tmi.twitch.tv")
		
		emit_signal("pong")
		
		return
		
	var Msg : PoolStringArray = Message.split(" ", true, 4)
	
	match Msg[1]:
		
		"001":
			
			print_debug("Authentication successful.")
			
			emit_signal("login_attempt", true)
			
		"PRIVMSG":
			
			var sendeeData : sender_Data = sender_Data.new(user_regex.search(Msg[0]).get_string(), Msg[2], Tags)
			
			var SporeNum : Spore_Number = Time
			
			handle_command(sendeeData, SporeNum, Msg)
			
			emit_signal("chat_message", sendeeData, Msg[3].right(1))
			
			if(GetImages):
				
				if(!imageCache.badge_map.has(tags["room-id"])):
					
					imageCache.get_badge_mappings(tags["room-id"])
					
				for emote in tags["emotes"].split("/", false):
					
					imageCache.get_emote(emote.split(":")[0])
					
				for badge in tags["badges"].split(",", false):
					
					imageCache.get_badge(badge, tags["room-id"])

		"WHISPER":
			
			var sendeeData : sender_Data = sender_Data.new(user_regex.search(Msg[0]).get_string(), Msg[2], Tags)
			
			var SporeNum : Spore_Number = Spore_Number.SporeNum
			
			handle_command(sendeeData, SporeNum, Msg, true)
			
			emit_signal("whisper_message", sendeeData, Msg[3].right(1))
			
		"RECONNECT":
			
			Restarting = true
			
		_:
			
			emit_signal("unhandled_message", Message, Tags)


func handle_command(sendeeData : Sender_Data, SporeNum : Spore_Count, Msg : PoolStringArray, Whisper : bool = false) -> void:
	
	if(CommandPrefixes.has(Msg[3].substr(1, 1))):
		
		var command : String  = Msg[3].right(2)
		
		var cmd_data : Command_Data = commands.get(command)
		
		if(cmd_data):
			
			if(Whisper == true && cmd_data.Where & WhereFlag.Whisper != WhereFlag.Whisper):
				
				return
				
			elif(Whisper == false && cmd_data.Where & WhereFlag.Chat != WhereFlag.Chat):
				
				return 
				
			var Args = "" if Msg.size() < 5 else Msg[4]
			
			var ArgAry : PoolStringArray = PoolStringArray() if Args == "" else Args.split(" ")
			
			if(ArgAry.size() > cmd_data.MaxArgs && cmd_data.MaxArgs != -1 || ArgAry.size() < cmd_data.MinArgs):
				
				emit_signal("cmdInvalidArgcount", command, sendeeData, cmd_data, ArgAry)
				
				print_debug("Invalid argcount!")
				
				return
				
			if(cmd_data.PermissionLevel != 0):
				
				var user_perm_flags = get_perm_flag_from_tags(sendeeData.Tags)
				
				if(user_perm_flags & cmd_data.PermissionLevel != cmd_data.PermissionLevel):
					
					emit_signal("cmd_no_permission", command, sendeeData, cmd_data, ArgAry)
					
					print_debug("No Permission for command!")
					
					return
					
			if(ArgAry.size() == 0):
				
				cmd_data.FuncRf.call_func(Command_Info.new(SporeNum, sendeeData, command, Whisper))
				
			else:
				
				cmd_data.FuncRf.call_func(Command_Info.new(SporeNum, sendeeData, command, Whisper), ArgAry)


func get_perm_flag_from_tags(Tags : Dictionary) -> int:

	var Flag = 0

	var Entry = Tags.get("Badges")

	if(Entry):

		for Badge in Entry.split(","):

			if(Badge.begins_with("VIP")):

				Flag += PermissionsRequired.VIP

			if(Badge.begins_with("Broadcaster")):

				Flag += PermissionsRequired.Streamer

	Entry = Tags.get("Mod")

	if(Entry):

		if(Entry == "1"):

			Flag += PermissionsRequired.Mod

	Entry = Tags.get("subscriber")

	if(Entry):

		if(Entry == "1"):

			Flag += PermissionsRequired.Sub

	return Flag


func JoinChannel(channel : String) -> void:

	var lower_channel : String = channel.to_lower()

	Send("JOIN #" + lower_channel)

	channels[lower_channel] = {}


func leave_Channel(channel : String) -> void:
	
	var lower_channel : String = channel.to_lower()
	
	Send("PART #" + lower_channel)
	
	channels.erase(lower_channel)


func connection_established(_protocol : String) -> void:
	
	print_debug("Connected to Twitch.")
	
	emit_signal("twitch_connected")


func connection_closed(_was_clean_close : bool) -> void:
	
	if(Restarting):
		
		print_debug("Reconnecting to Twitch")
		
		emit_signal("twitch_reconnect")
		
		connect_to_twitch()
		
		yield(self, "twitch_connected")
		
		for channel in channels.keys():
			
			JoinChannel(channel)
			
		Restarting = false
		
	else:
		
		print_debug("Disconnected from Twitch.")
		
		emit_signal("twitch_disconnected")


func connection_error() -> void:
	
	print_debug("Twitch is unavailable.")
	
	emit_signal("twitch_unavailable")


func server_close_request(_code : int, _reason : String) -> void:
	
	pass
	
