module main

import vweb
import rand
import os

const port = 8082

struct State {
mut:
	cnt int
}

struct App {
	vweb.Context
mut:
	state shared State
	lessons []Lesson = [
	Lesson{
		title: 'What is V?'
		id: 1
	}
	Lesson{
		title: 'Writing Our First Code'
		id: 2
	}
	Lesson{
		title: 'What is a Computer?'
		id: 3
	}]
}

struct Lesson {
	id int
	title string
	mut:
	body string // markdown
}

pub fn (app &App) before_request() {
	$if trace_before_request ? {
		eprintln('[vweb] before_request: ${app.req.method} ${app.req.url}')
	}
}

['/users/:user']
pub fn (mut app App) user_endpoint(user string) vweb.Result {
	id := rand.intn(100) or { 0 }
	return app.json({
		user: id
	})
}

pub fn (mut app App) index() vweb.Result {
	return $vweb.html()
}

['/lesson/:lesson_id']
pub fn (mut app App) lesson(lesson_id int) vweb.Result {
	/*
	for mut lesson in app.lessons {
		lesson.load_lesson_from_md_file()
	}
	lesson := app.lessons[0]
	*/
	mut lesson := app.lessons[lesson_id-1]
		lesson.load_lesson_from_md_file()
	println('!!!!!!!!')
	println(lesson)
	return $vweb.html()
}

fn (mut l Lesson) load_lesson_from_md_file() {
	println('load id=$l.id')
	files := os.ls('lessons/') or { return }
	for i, file in files {
		println(file)
		//id := i + 1
		if file.starts_with('${l.id}.') {
			println('got $file')
			l.body = os.read_file('lessons/' + file) or {return}
			println(l.body)
			return 
		}
	}


	//println(files)
}

pub fn (mut app App) show_text() vweb.Result {
	return app.text('Hello world from vweb')
}

pub fn (mut app App) cookie() vweb.Result {
	app.set_cookie(name: 'cookie', value: 'test')
	return app.text('Response Headers\n${app.header}')
}

[post]
pub fn (mut app App) post() vweb.Result {
	return app.text('Post body: ${app.req.data}')
}

fn main() {
	println('vweb example')
	vweb.run(&App{}, port)
}
