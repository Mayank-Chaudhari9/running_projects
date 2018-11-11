from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def homepage():
	title=" Home page"
	paragraph= ["it's going fine"," i am learnig great"]
	pageType= "homepage"
	return render_template("index.html", title=title, paragraph=paragraph,pageType=pageType)

@app.route('/about')
def aboutpage():
	title = "about me"
	paragraph = [" Loving to learn", "flask is cool"]
	pageType = "about"

	return render_template("index.html",title=title,paragraph=paragraph,pageType=pageType)

if __name__ == "__main__":
	app.run()





