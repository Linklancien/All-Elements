module main

import gg
import mana

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		width:        100 * 8
		height:       100 * 6
		window_title: '-Render Life-'
		user_data:    app
		bg_color:     bg_color
		frame_fn:     on_frame
		sample_count: 4
	)
	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	elements_list := [mana.Elements.water, mana.Elements.air, mana.Elements.fire, mana.Elements.earth]
	elements_quantity := [f32(1), 1, 1, 2]
	mana.mana_render(elements_list, elements_quantity, 400, 300, 0, 50, 20, app.ctx)
	app.ctx.end()
}
