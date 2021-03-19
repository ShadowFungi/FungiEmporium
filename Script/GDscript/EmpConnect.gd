extends Emp

onready var time = get_node("/root/Control/SporeTimer/")

export(String) var Account = ""

export(String) var ChannelName = ""

export(String) var OauthToken = ""

func _ready() -> void:
	
	
	
	websocket.connect("cmd_no_permission", self, "no_permission")
	
	connect_to_twitch()
	
	yield(self, "twitch_connected")
	
	AuthenticateOauth("SporesBot", "oauth:7ogasybr4fewoxijs0uu1420u75gnq")
	
	if(yield(self, "login_attempt") == false):
		
	  print("Invalid username or token.")
	
	  return
	
	JoinChannel(ChannelName)

	AddCommand("!spores", self, "SPORES")
	
	AddCommand("!test", self, "command_test")

	AddCommand("!helloworld", self, "hello_world")

	AddCommand("!greetme", self, "greet_me")

	AddCommand("!streameronly", self, "streamer_only", 0, 0, PermissionsRequired.Streamer)

	AddCommand("!greet", self, "greet", 1, 1)

	AddCommand("!list", self, "list", -1, 2)
	
	AddCommand("!join", self, "Join", 0, 0, PermissionsRequired.Everyone)

	AddAlias("test","test1")
	
	AddAlias("test","test2")
	
	AddAlias("test","test3")

	RemoveCommand("test2")

	RemoveCommand("test")

	RemoveCommand("test1")

	Chat("Connected")

	Chat("Connected", "<channel_name>")

	Whisper("TEST", "<channel_name>")

func command_test(_cmd_info : Command_Info) -> void:
	
	print("A")

func hello_world(_cmd_info : Command_Info) -> void:
	
	Chat("HELLO WORLD!")

func streamer_only(_cmd_info : Command_Info) -> void:
	
	Chat("Streamer command executed")

func no_permission(_cmd_info : Command_Info) -> void:
	
	Chat("NO PERMISSION!")

func greet(_cmd_info : Command_Info, ArgAry : PoolStringArray) -> void:
	
	Chat("Greetings, " + ArgAry[0])

func greet_me(_cmd_info : Command_Info) -> void:
	
	Chat("Greetings, " + _cmd_info.sendeeData.Tags["display-name"] + "!")

func list(_cmd_info : Command_Info, ArgAry : PoolStringArray) -> void:
	
	Chat(ArgAry.join(", "))
	

func planters_peanut_price(_cmd_info : Command_Info) -> void:
	
	Chat("planters peanuts currently cost, " + _cmd_info.sendeeData.Tags["display-name"] + " on amazon")


func SPORES(_cmd_info : Command_Info) -> void:
	
	var sporeNum = Time.SporeNum
	
	var sporeCount = floor(sporeNum)
	
	var spores = str(sporeCount)
	
	Chat("Spores released " + spores)
	
	Time.SporeNum -= Time.SporeNum

func Join(_cmd_info : Command_Info, SenderData : SendData) -> void:
	
	var UserName = SenderData.Usr
	
