module main

import markdown
import net.http
import os
import x.vweb

const port = 8082

const lessons_folder = 'lessons'

pub struct Context {
	vweb.Context
}

pub struct App {
	vweb.StaticHandler
mut:
	lessons map[string]Lesson
}

struct Lesson {
	id        string
	title     string
	filename  string
	available bool = true
mut:
	body string
}

pub fn (app &App) index(mut ctx Context) vweb.Result {
	return $vweb.html()
}

@['/lesson/:lesson_id']
pub fn (mut app App) lesson(mut ctx Context, lesson_id string) vweb.Result {
	lesson := app.lessons[lesson_id] or {
		Lesson{
			id: 'not_found'
		}
	}
	body := vweb.RawHtml(lesson.body)
	return $vweb.html()
}

fn (mut app App) load_lessons() ! {
	all_lesson_files := os.walk_ext(lessons_folder, '.md').sorted()
	for file in all_lesson_files {
		id := os.file_name(file).before('.')
		content := os.read_file(file) or {
			eprintln('Encountered error when loading lesson `${id}` `${file}`: ${err}')
			continue
		}
		println('Loading lesson ${file} ...')
		content_lines := content.split_into_lines()
		title := content_lines[0].trim_space()
		app.lessons[id] = Lesson{
			id: id
			title: title
			filename: file
			body: markdown.to_html(content_lines#[2..].join('\n'))
		}
	}
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
