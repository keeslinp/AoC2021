package main

import "core:fmt"
import "core:strings"
import "core:slice"

ROW_LEN :: 100 // I'm lazy
RAW_INPUT :: #load("./day9.txt")

main :: proc() {
  vals : [dynamic]u8
  defer delete(vals)
  h :: #force_inline proc(vals: []u8, x, y: int) -> u8 { return vals[y * ROW_LEN + x] }
  line_count := 0
  for c in RAW_INPUT {
    if (c != '\n') {
      append(&vals, c - '0')
    } else {
      line_count += 1
    }
  }
  low_points := make([dynamic]bool, len(vals))
  defer delete(low_points)
  for y in 0..<line_count {
    for x in 0..<ROW_LEN {
      current_height := h(vals[:], x, y)
      if (x > 0 && h(vals[:], x - 1, y) <= current_height) do continue
      if (y > 0 && h(vals[:], x, y - 1) <= current_height) do continue
      if (x + 1 < ROW_LEN && h(vals[:], x + 1, y) <= current_height) do continue
      if (y + 1 < line_count && h(vals[:], x, y + 1) <= current_height) do continue
      low_points[y * ROW_LEN + x] = true
    }
  }
  score_sum := 0
  for point, index in low_points {
    if (point) do score_sum += int(vals[index]) + 1
  }
  fmt.println(score_sum)

  basin_counted := make([dynamic]bool, len(vals))
  defer delete(basin_counted)
  top_three : [3]int
  for y in 0..<line_count {
    for x in 0..<ROW_LEN {
      index := y * ROW_LEN + x
      if (!low_points[index] || basin_counted[index]) do continue
      calc_basin_size :: proc(vals: []u8, basin_counted: []bool, x, y, line_count: int) -> (sum: int) {
        if basin_counted[y * ROW_LEN + x] do return 0
        basin_counted[y * ROW_LEN + x] = true
        current_height := h(vals, x, y)
        if current_height == 9 do return 0
        if (x > 0 && h(vals, x - 1, y) > current_height) do sum += calc_basin_size(vals, basin_counted, x - 1, y, line_count)
        if (y > 0 && h(vals, x, y - 1) > current_height) do sum += calc_basin_size(vals, basin_counted, x, y - 1, line_count)
        if (x + 1 < ROW_LEN && h(vals, x + 1, y) > current_height) do sum += calc_basin_size(vals, basin_counted, x + 1, y, line_count)
        if (y + 1< line_count && h(vals, x, y + 1) > current_height) do sum += calc_basin_size(vals, basin_counted, x, y + 1, line_count)
        return sum + 1
      }
      basin_size := calc_basin_size(vals[:], basin_counted[:], x, y, line_count)
      if basin_size > top_three[0] {
        top_three[0] = basin_size
        slice.sort(top_three[:]);
      }
    }
  }
  product := 1
  for size in top_three {
    product *= size
  }
  fmt.println(top_three, product)
}
