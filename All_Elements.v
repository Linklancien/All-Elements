module main

import gg
import mana {Mana_pool, Elements}

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	player_pool Mana_pool
	ext_pool	Mana_pool
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		width:        100 * 8
		height:       100 * 6
		window_title: '-Render Mana-'
		user_data:    app
		bg_color:     bg_color
		frame_fn:     on_frame
		sample_count: 4
	)

	app.player_pool = Mana_pool{
		elements_list:     [Elements.water, Elements.air, Elements.fire,
			Elements.earth]
		elements_quantity: [f32(1), 30, 25, 2]
	}

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.player_pool.render(300, 300, 50, app.ctx)
	app.ext_pool.render(600, 300, 50, app.ctx)
	app.ext_pool.absorbing(app.player_pool.rejecting(Mana_pool{[Elements.air], [f32(0.1)]}))
	app.ctx.end()
}
&,