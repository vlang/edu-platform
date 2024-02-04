module main

import json
import markdown
import net.http
import os
import rand
import x.vweb

const port = 8082

pub struct Context {
	vweb.Context
}

pub struct App {
	vweb.StaticHandler
mut:
	lessons []Lesson
}

struct Lesson {
	id        int
	title     string
	filename  string
	available bool = true
mut:
	body string
}

@['/users/:user']
pub fn (app &App) user_endpoint(mut ctx Context, user string) vweb.Result {
	id := rand.intn(100) or { 0 }
	return ctx.json({
		'id': id
	})
}

pub fn (app &App) index(mut ctx Context) vweb.Result {
	return $vweb.html()
}

@['/lesson/:lesson_id']
pub fn (mut app App) lesson(mut ctx Context, lesson_id int) vweb.Result {
	tmp := app.lessons.filter(it.id == lesson_id)
	lesson := tmp[0] or {
		Lesson{
			id: -1
		}
	}
	body := vweb.RawHtml(lesson.body)
	return $vweb.html()
}

fn (mut app App) load_lessons() ! {
	mut lessons := []Lesson{}
	for lesson in json.decode([]Lesson, os.read_file('lessons.json')!)! {
		if !lesson.available {
			eprintln('Skipping lesson with id ${lesson.id} as it is not available.')
			continue
		}
		lessons << Lesson{
			id: lesson.id
			title: lesson.title
			filename: lesson.filename
			body: markdown.to_html(os.read_file(os.join_path('lessons', lesson.filename)) or {
				eprintln('Encountered error when loading lesson ${lesson.id} (${lesson.filename}): ${err}')
				continue
			})
		}
	}
	app.lessons = lessons
}

pub fn (mut app App) show_text(mut ctx Context) vweb.Result {
	return ctx.text('Hello world from vweb')
}

pub fn (mut app App) cookie(mut ctx Context) vweb.Result {
	ctx.set_cookie(http.Cookie{ name: 'cookie', value: 'test' })
	return ctx.text('Response Headers\n${ctx.req.header}')
}

@[post]
pub fn (mut app App) post(mut ctx Context) vweb.Result {
	return ctx.text('Post body: ${ctx.req.data}')
}

fn main() {
	os.chdir(os.dir(os.executable()))!
	mut app := App{}
	app.mount_static_folder_at('assets', '/assets')!
	app.serve_static('/favicon.ico', 'assets/favicon.png')!
	app.load_lessons()!
	vweb.run[App, Context](mut app, port)
}
