module mana

import gg
import math

pub enum Elements {
	water
	fire
	earth
	air
}

//  RENDERING:
pub fn mana_render_parts(elements_list []Elements, elements_quantity []f32, x f32, y f32, radius f32, thickness f32, segments int, ctx gg.Context) {
	total := somme(elements_quantity)

	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)

	assert elements_list.len == elements_quantity.len, "Len aren't the same ${elements_list}, ${elements_quantity}"

	for index, element in elements_list {
		mut c := gg.Color{}
		match element {
			.water {
				c = gg.dark_blue
			}
			.fire {
				c = gg.dark_red
			}
			.earth {
				c = gg.dark_green
			}
			.air {
				c = gg.gray
			}
		}
		end_angle = math.pi * 2 / f32(total) * elements_quantity[index] + start_angle
		ctx.draw_arc_filled(x, y, radius, thickness, start_angle, end_angle, segments,
			c)
		start_angle = end_angle
	}
}

pub fn mana_render_taille(elements_list []Elements, elements_quantity []f32, x f32, y f32, radius f32, thickness f32, segments int, ctx gg.Context) {
	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)

	assert elements_list.len == elements_quantity.len, "Len aren't the same ${elements_list}, ${elements_quantity}"

	for index, element in elements_list {
		mut c := gg.Color{}
		match element {
			.water {
				c = gg.dark_blue
			}
			.fire {
				c = gg.dark_red
			}
			.earth {
				c = gg.dark_green
			}
			.air {
				c = gg.gray
			}
		}
		end_angle = math.pi * 2 / f32(elements_list.len) + start_angle
		ctx.draw_arc_filled(x, y, radius, 20 * elements_quantity[index], start_angle,
			end_angle, segments, c)
		start_angle = end_angle
	}
}

pub fn mana_render(elements_list []Elements, elements_quantity []f32, x f32, y f32, radius f32, thickness f32, segments int, ctx gg.Context) {
	total := somme(elements_quantity)

	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)

	assert elements_list.len == elements_quantity.len, "Len aren't the same ${elements_list}, ${elements_quantity}"

	for index, element in elements_list {
		mut c := gg.Color{}
		match element {
			.water {
				c = gg.dark_blue
			}
			.fire {
				c = gg.dark_red
			}
			.earth {
				c = gg.dark_green
			}
			.air {
				c = gg.gray
			}
		}
		end_angle = math.pi * 2 / f32(total) * elements_quantity[index] + start_angle
		ctx.draw_arc_filled(x, y, radius, thickness + elements_quantity[index], start_angle,
			end_angle, segments, c)
		start_angle = end_angle
	}
}

// MANA POOL:
pub struct Mana_pool {
pub mut:
	// Two list of the same size
	elements_list     []Elements
	elements_quantity []f32
}

pub fn (mana_pool Mana_pool) render(x f32, y f32, thickness f32, ctx gg.Context) {
	mana_render(mana_pool.elements_list, mana_pool.elements_quantity, x, y, 0, thickness,
		100, ctx)
}

pub fn (mut mana_pool Mana_pool) rejecting(other_mana_pool Mana_pool) Mana_pool {
	mut elements_list := []Elements{}
	mut elements_quantity := []f32{}

	for other_index, other_element in other_mana_pool.elements_list {
		mut new_quantity := f32(0.0)
		for index, element in mana_pool.elements_list {
			if element == other_element {
				quantity := other_mana_pool.elements_quantity[other_index]
				if mana_pool.elements_quantity[index] >= quantity {
					new_quantity = quantity
					mana_pool.elements_quantity[index] -= quantity
				} else {
					new_quantity = mana_pool.elements_quantity[index]
					mana_pool.elements_quantity[index] = 0.0
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

// USEFULL FN:
fn somme(list []f32) f32 {
	mut total := f32(0.0)
	for nb in list {
		total += nb
	}
	return total
}
