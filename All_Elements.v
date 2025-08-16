module main

import gg
import mana { Elements, Mana_pool }

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	player   Player
	ext_pool Mana_pool
}

struct Player {
mut:
	pool Mana_pool

	// Reject
	reject_air   Mana_pool = Mana_pool{[Elements.air], [f32(0.1)]}
	reject_fire  Mana_pool = Mana_pool{[Elements.fire], [f32(0.1)]}
	reject_earth Mana_pool = Mana_pool{[Elements.earth], [f32(0.1)]}
	reject_water Mana_pool = Mana_pool{[Elements.water], [f32(0.1)]}
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

	app.player.pool = Mana_pool{
		elements_list:     [Elements.water, Elements.air, Elements.fire, Elements.earth]
		elements_quantity: [f32(1), 30, 25, 2]
	}

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.player.pool.render(300, 300, 50, app.ctx)
	app.ext_pool.render(600, 300, 50, app.ctx)
	app.ext_pool.absorbing(mut app.player.pool.rejecting(app.player.reject_air))
	if app.player.pool.elements_quantity[1] == 0 {
		app.player.pool.absorbing(mut app.ext_pool)
	}
	app.ctx.end()
}
