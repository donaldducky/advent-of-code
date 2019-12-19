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

    let (station, len) = best_station(&asteroids);

    println!("Part 1: {}", len);
    println!("Part 2: {}", vaporized_asteroid(&station, &asteroids, 200));
}

fn best_station(asteroids: &Vec<Point>) -> (Point, usize) {
    let asteroids_copy = asteroids.clone();

    asteroids.iter()
        .map(|a| (*a, find_asteroids(*a, &asteroids_copy)))
        .max_by(|(_, d0), (_, d1)| d0.cmp(d1))
        .unwrap()
}

fn find_asteroids(a1: Point, asteroids: &Vec<Point>) -> usize {
    let normals: HashMap<Point, (Point, i32)> = asteroids.iter()
        .filter(|x| **x != a1)
        .fold(HashMap::new(), |mut acc, a2| {
            let v = vector(a1, *a2);
            let mag = magnitude(v);
            let n = normal_vector(v, mag);
            let d = dist(a1, *a2);

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

fn normal_vector(v: Point, mag: f64) -> Point {
    // Rust does not implement Eq for floats (ie. f64)
    // ...so we store 3 digits of precision as i32
    Point {
        x: ((v.x as f64 / mag) * 1000.0).trunc() as i32,
        y: ((v.y as f64 / mag) * 1000.0).trunc() as i32,
    }
}

fn vector(v1: Point, v2: Point) -> Point {
    Point {
        x: v2.x - v1.x,
        y: v2.y - v1.y,
    }
}

fn magnitude(v: Point) -> f64 {
    ((v.x * v.x + v.y * v.y) as f64).sqrt()
}

fn dist(v1: Point, v2: Point) -> i32 {
    (v2.y - v1.y).abs() + (v2.x - v1.x).abs()
}

fn angle_in_degrees(v: Point) -> f64 {
    // assuming we'll never be at origin
    if v.x == 0 {
        if v.y < 0 {
            0 as f64
        } else {
            180 as f64
        }
    } else if v.x < 0 {
        if v.y < 0 {
            // between 270 and 360 degrees
            (v.y as f64/v.x as f64).atan().to_degrees() + 270.0
        } else {
            // between 180 and 270 degrees
            (v.y as f64/v.x as f64).atan().to_degrees() + 270.0
        }
    } else {
        if v.y < 0 {
            // between 0 and 90 degrees
            (v.y as f64/v.x as f64).atan().to_degrees() + 90.0
        } else {
            // between 90 and 180 degrees
            (v.y as f64/v.x as f64).atan().to_degrees() + 90.0
        }
    }
}

fn vaporized_asteroid(station: &Point, asteroids: &Vec<Point>, n: usize) -> usize {
    let mut asteroids_by_angle: HashMap<usize, Vec<(Point, f64)>> = asteroids.iter()
        .filter(|a| **a != *station)
        .fold(HashMap::new(), |mut acc, a| {
            let v = vector(*station, *a);
            let m = magnitude(v);
            let angle = (angle_in_degrees(v) * 1000.0).trunc() as usize;

            let entries = acc.entry(angle).or_insert(Vec::new());
            (*entries).push((*a, m));

            acc
        });

    let mut asteroids_by_angle: Vec<_> = asteroids_by_angle.iter_mut()
        .map(|(angle, asteroids)| {
            asteroids.sort_by(|(_, m1), (_, m2)| m1.partial_cmp(m2).unwrap());
            (angle, asteroids)
        })
        .flat_map(|(angle, asteroids)| {
            asteroids.iter()
                .enumerate()
                .map(move |(i, (a, _))| (i*360000 + *angle, a))
        })
        .collect();

    asteroids_by_angle.sort_by(|(a, _), (b, _)| a.cmp(b));

    let (_, target) = asteroids_by_angle[n - 1];
    (target.x * 100 + target.y) as usize
}
