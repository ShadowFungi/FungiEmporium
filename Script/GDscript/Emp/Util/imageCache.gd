extends Node

class_name Image_Cache


signal BadgeMappingAvailable


var CachedImages : Dictionary = {"emotes": {}, "badges": {}}

var CacheMutex = Mutex.new()

var BadgeMap : Dictionary = {}

var BadgeMutex = Mutex.new()

var DlQueue : PoolStringArray = []

var DiskCache : bool

var DiskCachePath : String


var file : File = File.new()

var dir : Directory = Directory.new()

func _init(DoDiskCache : bool, CachePath : String) -> void:
	
	DiskCache = DoDiskCache
	
	DiskCachePath = CachePath

func _ready() -> void:

	if(DiskCache):

		for cache_dir in CachedImages.keys():

			CachedImages[cache_dir] = {}

			dir.make_dir_recursive(DiskCachePath + "/" + cache_dir)
			
			dir.open(DiskCachePath + "/" + cache_dir)

			dir.list_dir_begin(true)

			var current = dir.get_next()

			while current != "":

				if(!dir.current_is_dir()):

					file.open(dir.get_current_dir() + "/" + current, File.READ)

					var img : Image = Image.new()

					img.load_png_from_buffer(file.get_buffer(file.get_len()))

					file.close()

					var img_texture : ImageTexture = ImageTexture.new()

					img_texture.create_from_image(img, 0)

					CacheMutex.lock()

					CachedImages[cache_dir][current.get_basename()] = img_texture

					CacheMutex.unlock()

				current = dir.get_next()

		dir.open(DiskCachePath)

		dir.list_dir_begin(true)

		var current = dir.get_next()

		while current != "":

			if(!dir.current_is_dir()):

				file.open(DiskCachePath + "/" + current, File.READ)

				BadgeMap[current.get_basename()] = parse_json(file.get_as_text())["badge_sets"]

				file.close()

			current = dir.get_next()

	get_badge_mappings()

	yield(self, "BadgeMappingAvailable")

func create_request(url : String, resource : String, res_type : String) -> void:
	
	var RequestHTTP = HTTPRequest.new()
	
	RequestHTTP.connect("request_completed", self, "downloaded", [RequestHTTP, resource, res_type], CONNECT_ONESHOT)
	
	add_child(RequestHTTP)
	
	RequestHTTP.download_file = DiskCachePath + "/" + res_type + "/" + resource + ".png"
	
	RequestHTTP.request(url, [], false, HTTPClient.METHOD_GET)


func get_badge_mappings(channel_id : String = "") -> void:
	
	var url : String
	
	if(channel_id == ""):
	
		channel_id = "_global"
	
		url = "https://badges.twitch.tv/v1/badges/global/display"
	
	else:
	
		url = "https://badges.twitch.tv/v1/badges/channels/" + channel_id + "/display"
	
	if(!BadgeMap.has(channel_id)):
	
		var RequestHTTP = HTTPRequest.new()
	
		add_child(RequestHTTP)
	
		RequestHTTP.request(url, [], false, HTTPClient.METHOD_GET)
	
		RequestHTTP.connect("request_completed", self, "badge_mapping_received", [RequestHTTP, channel_id], CONNECT_ONESHOT)
	
	else:
	
		emit_signal("BadgeMappingAvailable")

func get_emote(id : String) -> ImageTexture:
	
	CacheMutex.lock()
	
	if(CachedImages["emotes"].has(id)):
	
		return CachedImages["emotes"][id]
	
	else:
	
		create_request("http://static-cdn.jtvnw.net/emoticons/v1/" + id + "/1.0", id, "emotes")
	
	CacheMutex.unlock()
	
	return null


func get_badge(badge_name : String, channel_id : String = "") -> ImageTexture:
	
	CacheMutex.lock()
	
	var badge_data : PoolStringArray = badge_name.split("/")
	
	if(CachedImages["badges"].has(badge_data[0])):
	
		return CachedImages["badges"][badge_data[0]]
	
	var channel : String
	
	if(!BadgeMap[channel_id].has(badge_data[0])):
	
		channel_id = "_global"
	
	create_request(BadgeMap[channel_id][badge_data[0]]["versions"][badge_data[1]]["image_url_1x"], badge_data[0], "badges")
	
	CacheMutex.unlock()
	
	return null


func downloaded(result : int, response_code : int, headers : PoolStringArray, body : PoolByteArray, request : HTTPRequest, id : String, type : String) -> void:
	
	if(type == "emotes"):
		
		get_parent().emit_signal("emote_downloaded", id)
	
	elif(type == "badges"):
	
		get_parent().emit_signal("badge_downloaded", id)
	
	request.queue_free()


func badge_mapping_received(result : int, response_copde : int, headers : PoolStringArray, body : PoolByteArray, request : HTTPRequest, id : String) -> void:
	
	BadgeMap[id] = parse_json(body.get_string_from_utf8())["badge_sets"]
	
	if(DiskCache):
		
		file.open(DiskCachePath + "/" + id + ".json", File.WRITE)
		
		file.store_buffer(body)
		
		file.close()
		
	emit_signal("BadgeMappingAvailable")
	
	request.queue_free()
