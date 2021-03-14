from godot import exposed, export

from godot import *

import cv2

from PIL import Image


ResNum = 0

image = "temp.png"

FFormat = ".png"

size = (32, 32)


@exposed
class EmoteTranslator(Node):
	
	def _on_Button_pressed():
		
		input = cv2.imread(image)

		# Get input size

		height, width = input.shape[:2]

		w, h = (size)


		temp = cv2.resize(input, (w, h), interpolation=cv2.INTER_LINEAR)


		# Initialize output image

		output = cv2.resize(temp, (width, height), interpolation=cv2.INTER_NEAREST)

		result = Image.fromarray(output)

		StrResNum = str(ResNum)

		result.save("result" + StrResNum + FFormat)


		cv2.imshow("'Input", input)


		cv2.imshow("Output", output)


		ResNum += 1

		print(ResNum)

		cv2.waitKey(0)


