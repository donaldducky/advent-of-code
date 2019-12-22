use std::cmp::Ordering;
use std::fmt;
use std::fs;
use regex::Regex;

#[derive(Eq,PartialEq,Hash,Copy,Clone)]
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

struct Moon {
    position: Point,
    velocity: Point,
}

impl Moon {
    fn potential_energy(&self) -> u32 {
        (self.position.x.abs() + self.position.y.abs() + self.position.z.abs()) as u32
    }

    fn kinetic_energy(&self) -> u32 {
        (self.velocity.x.abs() + self.velocity.y.abs() + self.velocity.z.abs()) as u32
    }

    fn total_energy(&self) -> u32 {
        self.potential_energy() * self.kinetic_energy()
    }
}

impl fmt::Display for Moon {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Pos {} Vel {}", self.position, self.velocity)
    }
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {}, {})", self.x, self.y, self.z)
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let re = Regex::new(r"^<x=(\-?\d+), y=(\-?\d+), z=(\-?\d+)>$").unwrap();

    let positions: Vec<Point> = input.trim()
        .lines()
        .map(|line| {
            let caps = re.captures(line).unwrap();

            let x = caps.get(1).map(|m| m.as_str()).unwrap().parse::<i32>().unwrap();
            let y = caps.get(2).map(|m| m.as_str()).unwrap().parse::<i32>().unwrap();
            let z = caps.get(3).map(|m| m.as_str()).unwrap().parse::<i32>().unwrap();

            Point{x: x, y: y, z: z}
        })
        .collect();

    println!("Part 1: {}", calculate_total_energy(positions, 1000));
}

fn calculate_total_energy(positions: Vec<Point>, n: usize) -> usize {
    let mut moons: Vec<Moon> = positions.iter()
        .map(|p| {
            Moon {
                position: *p,
                velocity: Point{x: 0, y: 0, z: 0},
            }
        })
        .collect();

    for _ in 0..n {
        // apply gravity
        let velocities = calc_velocities(&moons);

        moons.iter_mut()
            .zip(velocities.iter())
            .for_each(|(mut m, v)| {
                m.velocity.x += v.x;
                m.velocity.y += v.y;
                m.velocity.z += v.z;
            });

        // apply velocity
        moons.iter_mut()
            .for_each(|m| {
                m.position.x += m.velocity.x;
                m.position.y += m.velocity.y;
                m.position.z += m.velocity.z;
            });
    }

    //moons.iter().for_each(|m| println!("{}", m));

    let sum: u32 = moons.iter()
        .map(|m| m.total_energy())
        .sum();

    sum as usize
}

fn calc_velocities(moons: &Vec<Moon>) -> Vec<Point> {
    let moon_count = moons.len();
    let mut velocities = vec![Point{x: 0, y: 0, z: 0}; moons.len()];
    for i in 0..moon_count {
        for j in (i+1)..moon_count {
            let m1 = moons.get(i).unwrap();
            let m2 = moons.get(j).unwrap();

            match m1.position.x.cmp(&m2.position.x) {
                Ordering::Less => {
                    velocities[i].x += 1;
                    velocities[j].x -= 1;
                },
                Ordering::Greater => {
                    velocities[i].x -= 1;
                    velocities[j].x += 1;
                },
                Ordering::Equal => (),
            }

            match m1.position.y.cmp(&m2.position.y) {
                Ordering::Less => {
                    velocities[i].y += 1;
                    velocities[j].y -= 1;
                },
                Ordering::Greater => {
                    velocities[i].y -= 1;
                    velocities[j].y += 1;
                },
                Ordering::Equal => (),
            }

            match m1.position.z.cmp(&m2.position.z) {
                Ordering::Less => {
                    velocities[i].z += 1;
                    velocities[j].z -= 1;
                },
                Ordering::Greater => {
                    velocities[i].z -= 1;
                    velocities[j].z += 1;
                },
                Ordering::Equal => (),
            }
        }
    }

    velocities
}
