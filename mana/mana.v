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

	assert elements_list.len == elements_quantity.len, "Len aren't the same $elements_list, $elements_quantity"

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
	total := somme(elements_quantity)

	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)

	assert elements_list.len == elements_quantity.len, "Len aren't the same $elements_list, $elements_quantity"

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
		ctx.draw_arc_filled(x, y, radius, 20* elements_quantity[index], start_angle, end_angle, segments,
			c)
		start_angle = end_angle
	}
}

pub fn mana_render(elements_list []Elements, elements_quantity []f32, x f32, y f32, radius f32, thickness f32, segments int, ctx gg.Context) {
	total := somme(elements_quantity)

	mut start_angle := f32(0.0)
	mut end_angle := f32(0.0)

	assert elements_list.len == elements_quantity.len, "Len aren't the same $elements_list, $elements_quantity"

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
		ctx.draw_arc_filled(x, y, radius, thickness + elements_quantity[index], start_angle, end_angle, segments, c)
		start_angle = end_angle
	}
}

fn somme(list []f32) f32{
	mut total := f32(0.0)
	for nb in list{
		total += nb
	}
	return total
}
