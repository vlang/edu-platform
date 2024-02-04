module main

import markdown
import net.http
import os
import x.vweb

pub struct Context {
	vweb.Context
}

pub struct App {
	vweb.StaticHandler
mut:
	lessons      map[string]Lesson
	quit_enabled bool
}

struct Lesson {
	id       string
	title    string
	filename string
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
	all_lesson_files := os.walk_ext('lessons', '.md').sorted()
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

@[post]
pub fn (mut app App) quit_app(mut ctx Context) vweb.Result {
	if app.quit_enabled {
		ctx.takeover_conn()
		ctx.html('<h2>bye bye</h2>')
		exit(0)
	}
	return ctx.redirect('/')
}

fn main() {
	os.chdir(os.dir(os.executable()))!
	mut app := App{}
	$if quit_enabled ? {
		app.quit_enabled = true
	}
	app.mount_static_folder_at('assets', '/assets')!
	app.serve_static('/favicon.ico', 'assets/favicon.png')!
	app.load_lessons()!
	vweb.run[App, Context](mut app, 8082)
}
