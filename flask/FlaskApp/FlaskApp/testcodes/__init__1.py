from flask import Flask

app = Flask(__name__)

@app.route('/')
def homepage():
	return "hi there its mayank"



if __name__ == "__main__":
	app.run()