from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def homepage():
	
	return render_template("index.html", title="my first page", paragraph=["it's going fine"," i am learnig great"])



if __name__ == "__main__":
	app.run()