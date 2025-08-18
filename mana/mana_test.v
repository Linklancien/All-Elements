module mana

import rand
import arrays { sum }

fn test_difference() {
	minimum_mana_exchange := u32(1)
	for _ in 0 .. 100 {
		mana_pool1 := Mana_pool{
			elements_list:     [Elements.water]
			elements_quantity: [rand.u32_in_range(min_u32, max_u32) or { 0 }]
		}
		mana_pool2 := Mana_pool{
			elements_list:     [Elements.water]
			elements_quantity: [rand.u32_in_range(min_u32, max_u32) or { 0 }]
		}

		elements_graeter12, elements_lesser12 := difference(mana_pool1, mana_pool2, minimum_mana_exchange)
		elements_graeter21, elements_lesser21 := difference(mana_pool2, mana_pool1, minimum_mana_exchange)

		assert elements_graeter12 == elements_lesser21
		assert elements_graeter21 == elements_lesser12
	}
}

fn test_balancing() {
	// rand.seed([u32(0), 0])
	nb := 7
	tile_size := 50
	min_u32 := u32(0)
	max_u32 := u32(10)

	for _ in 0 .. 100 {
		mut mana_map := Mana_map{
			tile_size:             tile_size * 2
			minimum_mana_exchange: u32(1)
			x:                     tile_size
			y:                     tile_size
			mana_pool_list:        [][]Mana_pool{len: nb, init: []Mana_pool{len: nb, init: Mana_pool{
				render_const:      Render_const{
					thickness_max: tile_size
				}
				elements_list:     [Elements.water, Elements.air, Elements.fire, Elements.earth]
				elements_quantity: [rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 },
					rand.u32_in_range(min_u32, max_u32) or { 0 }]
			}}}
		}

		// Conservation de la matière:
		total1 := mana_map.total()
		mana_map.balancing()
		total2 := mana_map.total()

		assert total1 == total2, 'MANA is not conserved ${total1}, ${total2}'
	}
}

fn (mana_map Mana_map) total() f32 {
	mut total := f32(0)
	for column in mana_map.mana_pool_list {
		for mana_pool in column {
			total += sum(mana_pool.elements_quantity) or { panic('Haaaaaaaaaaaaaaaaaaaaaa') }
		}
	}
	return total
}
