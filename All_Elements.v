module main

import gg
import rand
import mana { Debug_type, Mana_pool }

const bg_color = gg.Color{0, 0, 0, 255}

enum Running_step {
	pause
	player_turn
	waiting_screen
	end_turns
}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	players []mana.Elementals

	debug_mode Debug_type = Debug_type.pie_chart
	game_state Running_step
}

fn main() {
	rand.seed([u32(0), 0])
	mut app := &App{}
	app.ctx = gg.new_context(
		width:        int(2 * tile_size * (map_size + 2))
		height:       int(2 * tile_size * map_size)
		window_title: '-Render Mana-'
		user_data:    app
		bg_color:     bg_color
		frame_fn:     on_frame
		event_fn:     on_event
		sample_count: 4
	)

	min_u32 := u32(0)
	max_u32 := u32(100)

	app.player.pool = Mana_pool{}
	app.player.focus_pool = Mana_pool{
		render_const: mana.Render_const{
			radius:        30
			thickness_min: 10
			thickness_max: 20
		}
	}

	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	match app.game_state {
		.player_turn {}
		.waiting_screen {}
		else {}
	}
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.e {
					app.player.focus_pool.absorbing(mut app.player.pool.rejecting(reject_air))
				}
				.r {
					app.player.focus_pool.absorbing(mut app.player.pool.rejecting(reject_earth))
				}
				.t {
					app.player.focus_pool.absorbing(mut app.player.pool.rejecting(reject_fire))
				}
				.y {
					app.player.focus_pool.absorbing(mut app.player.pool.rejecting(reject_water))
				}
				.d {
					app.player.pool.absorbing(mut app.player.focus_pool.rejecting(reject_air))
				}
				.f {
					app.player.pool.absorbing(mut app.player.focus_pool.rejecting(reject_earth))
				}
				.g {
					app.player.pool.absorbing(mut app.player.focus_pool.rejecting(reject_fire))
				}
				.h {
					app.player.pool.absorbing(mut app.player.focus_pool.rejecting(reject_water))
				}
				.space {
					match app.game_state {
						.pause {
							app.game_state = Running_step.running
						}
						else {
							app.game_state = Running_step.pause
						}
					}
				}
				.enter {
					match app.game_state {
						.step {
							app.game_state = Running_step.pause
						}
						else {
							app.game_state = Running_step.step
						}
					}
				}
				.p {
					app.debug_mode.next_debug()
				}
				else {}
			}
		}
		else {}
	}
}
