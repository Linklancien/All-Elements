module mana

import gg
import math
import arrays { max, sum }

pub enum Elements {
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
		.no {
			dtype = Debug_type.pie_chart
		}
		.pie_chart {
			dtype = Debug_type.no
		}
		else {
			dtype = Debug_type.no
		}
	}
}

//  RENDERING:
fn pie_chart(color_list []gg.Color, elements_quantity []u32, x f32, y f32, render_const Render_const, ctx gg.Context) {
	assert color_list.len == elements_quantity.len, "Len aren't the same ${color_list}, ${elements_quantity}"
	assert render_const.thickness_min <= render_const.thickness_max, 'error in struct Render_const ${render_const}'

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
	render_const Render_const
pub mut:
	// Two list of the same size
	elements_list     []Elements
	elements_quantity []u32
}

pub struct Render_const {
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
