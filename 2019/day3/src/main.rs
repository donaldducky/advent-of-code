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
    let mut steps: HashMap<_, HashMap<Point, u32>> = HashMap::new();

    for (i, wire) in input.lines().enumerate() {
        let mut wire_grid = HashSet::new();
        let mut wire_steps = HashMap::new();
        let mut step_count: u32 = 0;
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
                step_count = step_count + 1;
                current_position.x += direction.x;
                current_position.y += direction.y;
                wire_grid.insert(current_position);
                wire_steps.entry(current_position).or_insert(step_count);
            }
        }

        grid.insert(i, wire_grid);
        steps.insert(i, wire_steps);
    }

    let mut smallest_dist = 999999;
    let mut fewest_steps = 999999;
    for p in grid[&0].intersection(&grid[&1]) {
        let mdist = p.x.abs() + p.y.abs();
        smallest_dist = cmp::min(smallest_dist, mdist);

        let total_steps = steps[&0].get(p).unwrap() + steps[&1].get(p).unwrap();
        fewest_steps = cmp::min(fewest_steps, total_steps);
    }

    println!("Part 1: {}", smallest_dist);
    println!("Part 2: {}", fewest_steps);
}
