use intcode;
use intcode::Cmd;
use intcode::CPU;
use std::collections::HashMap;
use std::sync::mpsc;
use std::thread;

/*
Use intcode program.

Directions: 1=north, 2=south, 3=east, 4=west
Status codes: 0=wall, 1=move_1, 2=move_1_oxygen

Find oxygen by moving around.
Determine minimum commands to reach oxygen.
*/

#[derive(Debug, Clone, Copy)]
enum Direction {
    None = 0,
    North,
    South,
    East,
    West,
}

impl Direction {
    fn reverse(&self) -> Direction {
        match self {
            Direction::North => Direction::South,
            Direction::South => Direction::North,
            Direction::West => Direction::East,
            Direction::East => Direction::West,
            Direction::None => panic!("Cannot reverse Direction::None"),
        }
    }

    fn to_point(&self) -> Point {
        match self {
            Direction::North => Point::new(0, 1),
            Direction::South => Point::new(0, -1),
            Direction::West => Point::new(-1, 0),
            Direction::East => Point::new(1, 0),
            Direction::None => panic!("Cannot convert Direction::None to a point"),
        }
    }
}

const ALL_DIRECTIONS: [(Point, Direction); 4] = [
    (Point { x: 0, y: 1 }, Direction::North),
    (Point { x: 0, y: -1 }, Direction::South),
    (Point { x: -1, y: 0 }, Direction::West),
    (Point { x: 1, y: 0 }, Direction::East),
];

#[derive(Debug, Eq, PartialEq, Hash, Copy, Clone)]
struct Point {
    x: i128,
    y: i128,
}

impl Point {
    fn new(x: i128, y: i128) -> Point {
        Point { x: x, y: y }
    }

    fn expand(&self) -> Vec<(Point, Direction)> {
        ALL_DIRECTIONS
            .iter()
            .map(|(p, d)| (Point::new(self.x + p.x, self.y + p.y), d.clone()))
            .collect()
    }

    fn add(&self, p: Point) -> Point {
        Point::new(self.x + p.x, self.y + p.y)
    }
}

const WALL_TILE: i64 = -1;
const OXYGEN_TILE: i64 = -2;
#[derive(Debug)]
struct DroidState {
    position: Point,
    closed: HashMap<Point, i64>,
    path: Vec<Direction>,
    direction: Direction,
    oxygen_tank: Option<Point>,
}

impl DroidState {
    pub fn new() -> DroidState {
        let start = Point::new(0, 0);

        let mut state = DroidState {
            position: start,
            closed: HashMap::new(),
            path: vec![],
            direction: Direction::None,
            oxygen_tank: None,
        };

        state.visit(start, 0);

        state
    }

    pub fn get_next_direction(&mut self) -> Direction {
        let mut positions: Vec<Direction> = self
            .position
            .expand()
            .iter()
            .filter(|(p, _d)| !self.is_visited(*p))
            .map(|(_p, d)| d.clone())
            .collect();

        //println!( "Possible positions to move {:?} path {:?}", positions, self.path);
        match positions.len() {
            0 => {
                if self.path.len() > 0 {
                    // we cannot move anywhere, let's try to backtrack
                    self.path.pop().unwrap().reverse()
                } else {
                    Direction::None
                }
            }
            _ => positions.pop().unwrap(),
        }
    }

    fn visit(&mut self, position: Point, steps: i64) -> Option<i64> {
        self.closed.insert(position, steps)
    }

    fn is_visited(&self, position: Point) -> bool {
        self.closed.contains_key(&position)
    }

    fn draw(&self) {
        print!("\x1b[2J");
        let pad = 40;
        for y in ((self.position.y - pad)..(self.position.y + pad)).rev() {
            for x in (self.position.x - pad)..(self.position.x + pad) {
                if x == self.position.x && y == self.position.y {
                    print!("\x1b[32mD\x1b[0m");
                } else if x == 0 && y == 0 {
                    print!("\x1b[31mX\x1b[0m");
                } else {
                    match self.closed.get(&Point::new(x, y)) {
                        Some(v) => match *v {
                            WALL_TILE => print!("#"),
                            OXYGEN_TILE => print!("\x1b[44mO\x1b[0m"),
                            _other => print!("."),
                        },
                        None => print!(" "),
                    }
                }
            }
            println!("");
        }
        println!("");
        std::thread::sleep(std::time::Duration::from_millis(50));
    }
}

fn main() {
    let filename = "input.txt";
    let program = intcode::read_program(filename);

    println!("Part 1: {}", part1(program.clone()));
    println!("Part 2: {}", part2(program.clone()));
}

fn part1(program: Vec<i128>) -> usize {
    let state = explore(program, false);

    state.path.len()
}

fn part2(program: Vec<i128>) -> usize {
    let state = explore(program, true);

    //state.draw();
    //println!("Exploring complete! Oxygen tank at {:?}", oxygen_tank);

    // ok let's flood fill the oxygen
    let mut j = 0;

    // Insert all of the non-wall locations into a HashMap.
    // We can use this to determine if any spaces still need oxygen.
    // If the Point exists in the map, oxygen has not filled that location.
    let mut to_fill: HashMap<Point, i64> = state
        .closed
        .clone()
        .iter()
        .filter(|(_p, v)| **v != WALL_TILE)
        .fold(HashMap::new(), |mut acc, (p, v)| {
            acc.insert(p.clone(), *v);
            acc
        });

    let mut open: Vec<Point> = vec![state.oxygen_tank.unwrap()];
    while open.len() > 0 {
        let mut next: Vec<Point> = vec![];

        while open.len() > 0 {
            let current = open.pop().unwrap();
            let filtered: Vec<Point> = current
                .expand()
                .iter()
                .filter(|(p, _d)| to_fill.contains_key(p))
                .map(|(p, _d)| p.clone())
                .collect();
            filtered.iter().for_each(|p| {
                to_fill.remove(p);
            });
            next.extend(filtered);
        }
        open = next;

        j += 1;
    }

    // do not count initial oxygen location
    j - 1
}

fn explore(program: Vec<i128>, entire_map: bool) -> DroidState {
    let mut cpu = CPU::new("day15".to_string(), program);

    let (cpu_tx, robot_rx) = mpsc::channel();
    let (robot_tx, cpu_rx) = mpsc::channel();

    let cpu_handle = thread::Builder::new()
        .name("cpu".to_string())
        .spawn(move || {
            cpu.run(&cpu_tx, &cpu_rx);
        })
        .unwrap();

    let robot_handle = thread::Builder::new()
        .name("robot".to_string())
        .spawn(move || {
            let mut i = 0;
            let max_i = 10000;

            let mut state = DroidState::new();

            loop {
                i += 1;

                match robot_rx.recv().unwrap() {
                    Cmd::Halt() => break,
                    Cmd::Output(out) => {
                        match out {
                            0 => {
                                state.visit(state.position, WALL_TILE);
                                state.position =
                                    state.position.add(state.direction.reverse().to_point());
                                state.path.pop();
                            }
                            1 => {
                                state.visit(state.position, state.path.len() as i64);
                            }
                            2 => {
                                //state.draw();
                                //println!("\x1b[31mFound Oxygen!\x1b[0m @{:?}", state.position);
                                //println!("Took {} steps", state.path.len());
                                state.oxygen_tank = Some(state.position);
                                state.visit(state.position, OXYGEN_TILE);
                                if !entire_map {
                                    break;
                                }
                            }
                            _ => panic!("Unknown output response {}", out),
                        }

                        if i > max_i - 100 {
                            println!("<- {:<10} {:?}", out, state);
                        }
                        if i % 10 == 0 {
                            //state.draw();
                        }
                    }
                    Cmd::RequestInput() => {
                        match state.get_next_direction() {
                            Direction::None => {
                                // We are done exploring
                                break;
                            }
                            d => {
                                state.direction = d;
                                state.position = state.position.add(state.direction.to_point());
                                if !state.is_visited(state.position) {
                                    state.path.push(d);
                                }

                                robot_tx.send(Cmd::Input(d as i128)).unwrap();
                            }
                        }
                    }
                    _ => panic!("Unhandled command"),
                }

                if i == max_i {
                    panic!("Quitting after {} iterations", i);
                }
            }

            state
        })
        .unwrap();

    cpu_handle.join().unwrap();
    robot_handle.join().unwrap()
}

#[cfg(test)]
mod tests {
    use crate::part1;

    #[test]
    fn part1_test() {
        let input = "".to_string();

        //assert_eq!(part1(input), 0);
    }
}
