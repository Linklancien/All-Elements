module main

import gg
import rand
import mana

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
	mana.Players_info
mut:
	ctx &gg.Context = unsafe { nil }
}

fn main() {
	rand.seed([u32(0), 0])
	w := 800
	h := 600
	mut app := &App{}
	app.ctx = gg.new_context(
		width:        w
		height:       h
		window_title: '-Render Mana-'
		user_data:    app
		bg_color:     bg_color
		frame_fn:     on_frame
		event_fn:     on_event
		sample_count: 4
	)

	app.players = mana.prepare_game(2, w, h)
	app.center = mana.Pos{
		x: w / 2
		y: h / 2
	}

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.render(app.ctx, app.debug_mode)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	app.action(e)
}
