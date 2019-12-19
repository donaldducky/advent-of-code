use std::collections::HashMap;
use std::fs;

#[derive(Eq,PartialEq,Hash,Copy,Clone)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let input = input.trim();

    println!("Part 1: {}", best_asteroid_count(input.clone()));
}

fn best_asteroid_count(input: &str) -> usize {
    let asteroids: Vec<Point> = input.lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars()
                .enumerate()
                .map(move |(x, c)| (x, y, c))
        })
        .filter(|(_x, _y, c)| *c == '#')
        .map(|(x, y, _)| {
            Point {
                x: x as i32,
                y: y as i32
            }
        })
        .collect();

    let asteroids_copy = asteroids.clone();

    asteroids.iter()
        .map(|a| find_asteroids(*a, &asteroids_copy))
        .max()
        .unwrap()
}

fn find_asteroids(a1: Point, asteroids: &Vec<Point>) -> usize {
    let normals: HashMap<Point, (Point, i32)> = asteroids.iter()
        .filter(|x| **x != a1)
        .fold(HashMap::new(), |mut acc, a2| {
            let v = Point {
                x: (a2.x - a1.x),
                y: (a2.y - a1.y),
            };
            let d = (a2.y - a1.y).abs() + (a2.x - a1.x).abs();
            let mag = ((v.x * v.x + v.y * v.y) as f64).sqrt();
            // Rust does not implement Eq for floats (ie. f64)
            // ...so we store 3 digits of precision as i32
            let n = Point {
                x: ((v.x as f64 / mag) * 1000.0).trunc() as i32,
                y: ((v.y as f64 / mag) * 1000.0).trunc() as i32,
            };

            match acc.get(&n) {
                Some((_a0, d0)) => {
                    if d < *d0 {
                        *acc.get_mut(&n).unwrap() = (*a2, d);
                    }
                    acc
                },
                None => {
                    acc.insert(n, (*a2, d));
                    acc
                }
            }
        });

    normals.len()
}
