use std::cmp;
use std::fmt;
use std::fs;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(Eq, PartialEq, Hash, Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}


fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let input = input.trim();

    let mut current_position: Point;
    let mut grid: HashMap<_, HashSet<Point>> = HashMap::new();

    for (i, wire) in input.lines().enumerate() {
        let mut wire_grid = HashSet::new();
        current_position = Point {x: 0, y: 0 };

        for p in wire.split(",") {
            let dir = &p[0..1];
            let count = (&p[1..]).parse::<u32>().unwrap();
            let direction = match dir {
                "U" => Point { x: 0, y: 1 },
                "D" => Point { x: 0, y: -1 },
                "L" => Point { x: -1, y: 0 },
                "R" => Point { x: 1, y: 0 },
                _ => panic!("unknown direction {}", dir),
            };

            for _j in 0..count {
                current_position.x += direction.x;
                current_position.y += direction.y;
                wire_grid.insert(current_position);
            }
        }

        grid.insert(i, wire_grid);
    }

    let mut smallest_dist = 999999;
    for p in grid[&0].intersection(&grid[&1]) {
        let mdist = p.x.abs() + p.y.abs();
        smallest_dist = cmp::min(smallest_dist, mdist);
    }

    println!("Part 1: {}", smallest_dist);
}
