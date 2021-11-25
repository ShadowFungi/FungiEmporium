extends Control


var websocket := WebSocketClient.new()


func chat_message(data : SenderData, msg : String) -> void:
	$ChatContainer.put_chat(data, msg)

# Check the CommandInfo class for the available info of the cmd_info.
func command_test(cmd_info : CommandInfo) -> void:
	print("A")

func hello_world(cmd_info : CommandInfo) -> void:
	$Gift.chat("HELLO WORLD!")

func streamer_only(cmd_info : CommandInfo) -> void:
	$Gift.chat("Streamer command executed")

func no_permission(cmd_info : CommandInfo) -> void:
	$Gift.chat("NO PERMISSION!")

func greet(cmd_info : CommandInfo, arg_ary : PoolStringArray) -> void:
	$Gift.chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
	$Gift.chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func list(cmd_info : CommandInfo, arg_ary : PoolStringArray) -> void:
	$Gift.chat(arg_ary.join(", "))

func Spores(cmd_info : CommandInfo) -> void:
	var SporeNo = String(floor($SporeTimer.sporeNum))
	$Gift.chat("Spores Released " + SporeNo)
	print("Spores Released " + SporeNo)
	$SporeTimer.sporeNum = 0

func Join(cmd_info : CommandInfo):
	var img = ImageCache.new(false, "user://gift/cache")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
	var error = http_request.request("https://api.twitch.tv/helix/users?login=" + cmd_info.sender_data.user, ["Authorization: Bearer 72fspolhaclaeo2wczzmydxa2fj0vf", "Client-Id: d4htp1qv7dc7v6y8k4v4iz3gnllm8w"])
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print(response.keys())
