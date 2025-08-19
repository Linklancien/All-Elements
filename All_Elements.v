module main

import gg
import rand
import mana { Elements, Mana_map, Mana_pool }

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	player   Player
	ext_pool Mana_pool
	mana_map Mana_map
}

struct Player {
mut:
	pool Mana_pool

	// Reject
	reject_air   Mana_pool = Mana_pool{
		elements_list:     [Elements.air]
		elements_quantity: [u32(0.1)]
	}
	reject_fire  Mana_pool = Mana_pool{
		elements_list:     [Elements.fire]
		elements_quantity: [u32(0.1)]
	}
	reject_earth Mana_pool = Mana_pool{
		elements_list:     [Elements.earth]
		elements_quantity: [u32(0.1)]
	}
	reject_water Mana_pool = Mana_pool{
		elements_list:     [Elements.water]
		elements_quantity: [u32(0.1)]
	}
}

fn main() {
	rand.seed([u32(0), 0])
	mut app := &App{}
	app.ctx = gg.new_context(
		width:        100 * 8
		height:       100 * 6
		window_title: '-Render Mana-'
		user_data:    app
		bg_color:     bg_color
		frame_fn:     on_frame
		event_fn:     on_event
		sample_count: 4
	)

	app.player.pool = Mana_pool{
		render_const:      mana.Render_const{
			radius:        20
			thickness_min: 10
			thickness_max: 20
		}
		elements_list:     [Elements.water, Elements.air, Elements.fire, Elements.earth]
		elements_quantity: [u32(1), 30, 25, 2]
	}

	nb := 7
	tile_size := 50
	min_u32 := u32(0)
	max_u32 := u32(100)
	app.mana_map = Mana_map{
		tile_size:             tile_size * 2
		minimum_mana_exchange: 1
		x:                     tile_size
		y:                     tile_size
		mana_pool_list:        [][]Mana_pool{len: nb, init: []Mana_pool{len: nb + index - index, init: Mana_pool{
			render_const:      mana.Render_const{
				thickness_max: tile_size
			}
			elements_list:     [Elements.water, Elements.air, Elements.fire, Elements.earth]
			elements_quantity: [rand.u32_in_range(min_u32, max_u32) or { 0 },
				rand.u32_in_range(min_u32, max_u32) or { 0 },
				rand.u32_in_range(min_u32, max_u32) or { 0 },
				rand.u32_in_range(min_u32, max_u32) or { 0 }]
		}}}
	}

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.mana_map.balancing()

	app.ctx.begin()
	app.mana_map.render(app.ctx, mana.Debug_type.numbers)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.e {
					app.ext_pool.absorbing(mut app.player.pool.rejecting(app.player.reject_air))
				}
				.r {
					app.ext_pool.absorbing(mut app.player.pool.rejecting(app.player.reject_earth))
				}
				.t {
					app.ext_pool.absorbing(mut app.player.pool.rejecting(app.player.reject_fire))
				}
				.y {
					app.ext_pool.absorbing(mut app.player.pool.rejecting(app.player.reject_water))
				}
				.d {
					app.player.pool.absorbing(mut app.ext_pool.rejecting(app.player.reject_air))
				}
				.f {
					app.player.pool.absorbing(mut app.ext_pool.rejecting(app.player.reject_earth))
				}
				.g {
					app.player.pool.absorbing(mut app.ext_pool.rejecting(app.player.reject_fire))
				}
				.h {
					app.player.pool.absorbing(mut app.ext_pool.rejecting(app.player.reject_water))
				}
				else {}
			}
		}
		else {}
	}
}
