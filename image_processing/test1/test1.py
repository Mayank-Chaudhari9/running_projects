from PIL import Image

import numpy as np
# Reading image and displaying as array [R G B A]
i = Image.open('images/dot.png')
iar=np.asarray(i)
print(iar)