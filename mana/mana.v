module mana

import gg
import math
import rand
import arrays { max, sum }

pub enum Elements {
	empty
	water
	fire
	earth
	air
}

// map[Elements]gg.Color
pub const elements_color = {
	Elements.water: gg.dark_blue
	Elements.fire:  gg.dark_red
	Elements.earth: gg.dark_green
	Elements.air:   gg.gray
}

// Reject
const reject_water = Mana_pool{
	elements_list:     [Elements.water]
	elements_quantity: [u32(1)]
}
const reject_fire = Mana_pool{
	elements_list:     [Elements.fire]
	elements_quantity: [u32(1)]
}
const reject_earth = Mana_pool{
	elements_list:     [Elements.earth]
	elements_quantity: [u32(1)]
}
const reject_air = Mana_pool{
	elements_list:     [Elements.air]
	elements_quantity: [u32(1)]
}

pub enum Debug_type {
	no
	pie_chart
	numbers
}

pub fn (mut dtype Debug_type) next_debug() {
	match *dtype {
		.no {
			dtype = Debug_type.pie_chart
		}
		.pie_chart {
			dtype = Debug_type.numbers
		}
		.numbers {
			dtype = Debug_type.no
		}
	}
}

pub fn (mut dtype Debug_type) next() {
	match *dtype {
		.numbers {
			dtype = Debug_type.pie_chart
		}
		.pie_chart {
			dtype = Debug_type.numbers
		}
		else {
			dtype = Debug_type.numbers
		}
	}
}

//  RENDERING:
fn pie_chart(color_list []gg.Color, elements_quantity []u32, x f32, y f32, render_const Mana_pool_render_const, ctx gg.Context) {
	assert color_list.len == elements_quantity.len, "Len aren't the same ${color_list}, ${elements_quantity}"
	assert render_const.thickness_min <= render_const.thickness_max, 'error in struct Mana_pool_render_const ${render_const}'

	total := sum(elements_quantity) or { 0 }
	thickness_const := (render_const.thickness_max - render_const.thickness_min) / max(elements_quantity) or {
		0
	}

	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)
	for index, c in color_list {
		quantity := elements_quantity[index]
		if quantity != 0 {
			end_angle = math.pi * 2 * f32(quantity) / f32(total) + start_angle
			thickness := render_const.thickness_min + thickness_const * quantity

			ctx.draw_arc_filled(x, y, render_const.radius, thickness, start_angle, end_angle,
				render_const.segments, c)

			start_angle = end_angle
		}
	}
}

// MANA POOL:
pub struct Mana_pool {
pub:
	render_const Mana_pool_render_const
pub mut:
	// Two list of the same size
	elements_list     []Elements
	elements_quantity []u32
}

pub struct Mana_pool_render_const {
pub:
	radius        f32
	thickness_min f32 = 30
	thickness_max f32 = 50
	segments      int = 100
}

// UI
pub fn (mana_pool Mana_pool) render(ctx gg.Context, x f32, y f32, size f32, debug Debug_type) {
	match debug {
		.pie_chart {
			pie_chart(mana_pool.get_color_list(), mana_pool.elements_quantity, x, y, mana_pool.render_const,
				ctx)
		}
		.no {
			most := mana_pool.most_of_element()
			c := elements_color[most]
			ctx.draw_rect_filled(x - size / 2, y - size / 2, size, size, c)
		}
		.numbers {
			for index, element in mana_pool.elements_list {
				description := '${element}: ${mana_pool.elements_quantity[index]}'
				ctx.draw_text_default(int(x), int(y + index * 8), description)
			}
		}
	}
}

fn (mana_pool Mana_pool) get_color_list() []gg.Color {
	mut color_list := []gg.Color{cap: mana_pool.elements_list.len}
	for element in mana_pool.elements_list {
		color_list << elements_color[element]
	}
	return color_list
}

fn (mana_pool mana_pool) get_quantity(element Elements) u32{
	for index, elem in mana_pool.elements_list{
		if elem == element{
			return mana_pool.elements_quantity[index]
		}
	}
	return 0
}

// FN
pub fn (mut mana_pool Mana_pool) rejecting(other_mana_pool Mana_pool) Mana_pool {
	mut elements_list := []Elements{}
	mut elements_quantity := []u32{}

	for other_index, other_element in other_mana_pool.elements_list {
		mut new_quantity := u32(0.0)
		for index, element in mana_pool.elements_list {
			if element == other_element {
				quantity := other_mana_pool.elements_quantity[other_index]
				if mana_pool.elements_quantity[index] >= quantity {
					new_quantity = quantity
					mana_pool.elements_quantity[index] -= quantity
				} else {
					new_quantity = mana_pool.elements_quantity[index]
					mana_pool.elements_quantity[index] = u32(0)
				}
				break
			}
		}

		if new_quantity > 0 {
			elements_list << [other_element]
			elements_quantity << [new_quantity]
		}
	}

	return Mana_pool{
		elements_list:     elements_list
		elements_quantity: elements_quantity
	}
}

pub fn (mut mana_pool Mana_pool) absorbing(mut other_mana_pool Mana_pool) {
	for other_index, other_element in other_mana_pool.elements_list {
		mut not_merged := true
		for index, element in mana_pool.elements_list {
			if other_element == element {
				not_merged = false
				mana_pool.elements_quantity[index] += other_mana_pool.elements_quantity[other_index]
				break
			}
		}

		if not_merged {
			mana_pool.elements_list << [other_element]
			mana_pool.elements_quantity << other_mana_pool.elements_quantity[other_index]
		}
	}
	other_mana_pool = Mana_pool{}
}

fn (mana_pool Mana_pool) most_of_element() Elements {
	if mana_pool.elements_list.len == 0 {
		return Elements.empty
	}
	mut max_id := 0
	mut max := mana_pool.elements_quantity[0]
	for index, quantity in mana_pool.elements_quantity {
		if max < quantity {
			max = quantity
			max_id = index
		}
	}

	return mana_pool.elements_list[max_id]
}

// WORLD MAP
pub struct Mana_map {
pub:
	tile_size             f32
	minimum_mana_exchange u32
pub mut:
	x              f32
	y              f32
	mana_pool_list [][]Mana_pool
}

pub fn (mut mana_map Mana_map) balancing() {
	mana_pool_list_sav := mana_map.mana_pool_list.clone()
	x_max := mana_map.mana_pool_list.len
	y_max := mana_map.mana_pool_list[0].len
	for x in 0 .. x_max {
		for y in 0 .. y_max {
			neighbors := [[x - 1, y], [x + 1, y], [x, y - 1],
				[x, y + 1]]
			for adj in neighbors {
				if adj[0] > -1 && adj[0] < x_max && adj[1] > -1 && adj[1] < y_max {
					element_greater, element_smaller := difference(mana_pool_list_sav[x][y],
						mana_pool_list_sav[adj[0]][adj[1]], mana_map.minimum_mana_exchange)
					for index, element in mana_pool_list_sav[x][y].elements_list {
						if element in element_greater {
							mana_map.mana_pool_list[x][y].elements_quantity[index] += mana_map.minimum_mana_exchange
						} else if element in element_smaller {
							mana_map.mana_pool_list[x][y].elements_quantity[index] -= mana_map.minimum_mana_exchange
						}
					}
				}
			}
		}
	}
}

fn difference(mana_pool1 Mana_pool, mana_pool2 Mana_pool, minimum_mana_exchange u32) ([]Elements, []Elements) {
	// return a list of all the elements that a more present in the second mana_pool
	mut element_greater := []Elements{}
	mut element_smaller := []Elements{}

	for index1, element1 in mana_pool1.elements_list {
		for index2, element2 in mana_pool2.elements_list {
			if element1 == element2 {
				if mana_pool1.elements_quantity[index1] + minimum_mana_exchange < mana_pool2.elements_quantity[index2] {
					element_greater << element1
				} else if mana_pool2.elements_quantity[index2] + minimum_mana_exchange < mana_pool1.elements_quantity[index1] {
					element_smaller << element1
				}
			}
		}
	}

	return element_greater, element_smaller
}

pub fn (mana_map Mana_map) render(ctx gg.Context, debug Debug_type) {
	for x in 0 .. mana_map.mana_pool_list.len {
		for y in 0 .. mana_map.mana_pool_list[0].len {
			pos_x := x * mana_map.tile_size + mana_map.x
			pos_y := y * mana_map.tile_size + mana_map.y
			mana_map.mana_pool_list[x][y].render(ctx, pos_x, pos_y, mana_map.tile_size,
				debug)
		}
	}
}

// ELEMENTALS:
pub struct Elementals {
	Elementals_render_const
pub mut:
	pool       Mana_pool
	focus_pool Mana_pool
	// here is the index of the cible
	target int
}

// 1: used for rendering during it's own turn
// 2: used for rendering the information the ennemi is allowed to see
pub struct Elementals_render_const {
pub:
	size f32 = 10
	// 1:
	focus_pool_x f32
	focus_pool_y f32
	// 2:
	pool_x f32
	pool_y f32
}

// spell
fn (mut elemental Elementals) spell_cast(quantity Mana_pool, is_reverse bool) {
	if is_reverse {
		elemental.pool.absorbing(mut elemental.focus_pool.rejecting(quantity))
	} else {
		elemental.focus_pool.absorbing(mut elemental.pool.rejecting(quantity))
	}
}

// rendering

// 1: render the elemental's mana pools
fn (elemental Elementals) self_render(ctx gg.Context, debug Debug_type) {
	// 1:
	elemental.pool.render(ctx, elemental.pool_x, elemental.pool_y, elemental.size, debug)
	elemental.focus_pool.render(ctx, elemental.focus_pool_x, elemental.focus_pool_y, elemental.size,
		debug)
}

// 1: render the information
fn (elemental Elementals) ennemi_render(ctx gg.Context, debug Debug_type) {
	// 1:
	elemental.pool.render(ctx, elemental.pool_x, elemental.pool_y, elemental.size, .pie_chart)
}

// list of concurents:
// 1: calcul some const
// 2: calcul the postion of each player using their index (no finish)/ can be change to initialise the array directly
pub fn prepare_game(numbers int, width int, height int) []Elementals {
	// 1:
	x_possible := [int(width / 6), int(width * 5 / 6)]
	height_dif := height / numbers

	center_x := width / 2
	center_y := height / 2

	min_u32 := u32(0)
	max_u32 := u32(100)

	mut list_player := []Elementals{}
	// 2:
	for id in 0 .. numbers {
		x := x_possible[id % 2]
		y := height_dif * ((id / 2) + 1)
		list_player << Elementals{
			focus_pool_x: center_x
			focus_pool_y: center_y
			pool_x:       x
			pool_y:       y
			pool:         Mana_pool{
				elements_list:     [Elements.water, Elements.air, Elements.fire, Elements.earth]
				elements_quantity: [rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 }]
			}
		}
	}

	return list_player
}

//
enum Running_step {
	main_menu
	pause
	player_turn
	waiting_screen
	end_turns
	end_game
}

pub struct Pos {
pub:
	x int
	y int
}

pub struct Players_info {
pub mut:
	center     Pos
	players    []Elementals
	game_state Running_step
	debug_mode Debug_type = Debug_type.pie_chart
	id_turn    int
}

pub fn (info Players_info) render(ctx gg.Context, debug Debug_type) {
	match info.game_state {
		.main_menu {
			ctx.draw_text_default(info.center.x, info.center.y, 'MAIN MENU')
		}
		.waiting_screen {
			ctx.draw_text_default(info.center.x, info.center.y, 'WAITING SCREEN')
			ctx.draw_text_default(info.center.x, info.center.y + 8, 'NEXT PLAYER: ${info.id_turn}')
		}
		.end_turns{
			ctx.draw_text_default(info.center.x, info.center.y, 'END TURNS')
		}
		.end_game{
			ctx.draw_text_default(info.center.x, info.center.y, 'END GAME')
		}
		.player_turn {
			for index, elemental in info.players {
				if index == info.id_turn {
					elemental.self_render(ctx, debug)
				} else {
					elemental.ennemi_render(ctx, debug)
				}
			}
		}
		else {}
	}
}

pub fn (mut info Players_info) action(e &gg.Event) {
	match e.typ {
		.key_down {
			match e.key_code {
				.p {
					info.debug_mode.next()
				}
				.enter {
					info.next_game_state()
				}
				.e {
					info.players[info.id_turn].spell_cast(reject_air, e.modifiers == 1)
				}
				.r {
					info.players[info.id_turn].spell_cast(reject_earth, e.modifiers == 1)
				}
				.t {
					info.players[info.id_turn].spell_cast(reject_fire, e.modifiers == 1)
				}
				.y {
					info.players[info.id_turn].spell_cast(reject_water, e.modifiers == 1)
				}
				else {}
			}
		}
		else {}
	}
}

fn (mut info Players_info) deal_damage() []int {
	for player in info.player{

	}
	return []int{}
}

fn (mut info Players_info) next_game_state() {
	match info.game_state {
		.main_menu {
			info.id_turn = 0
			info.game_state = .waiting_screen
		}
		.player_turn {
			if info.id_turn == info.players.len - 1 {
				info.id_turn = 0
				info.game_state = .end_turns
			} else {
				info.id_turn += 1
				info.game_state = .waiting_screen
			}
		}
		.waiting_screen {
			info.game_state = .player_turn
		}
		.end_turns {
			defeat := info.deal_damage()
			if defeat.len == 0 {
				info.game_state = .waiting_screen
			} else {
				info.game_state = .end_game
			}
		}
		.end_game {
			info.game_state = .main_menu
		}
		else {}
	}
}
