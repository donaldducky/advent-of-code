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
#[derive(Debug)]
struct DroidState {
    position: Point,
    closed: HashMap<Point, i64>,
    path: Vec<Direction>,
    direction: Direction,
}

impl DroidState {
    pub fn new() -> DroidState {
        let start = Point::new(0, 0);

        let mut state = DroidState {
            position: start,
            closed: HashMap::new(),
            path: vec![],
            direction: Direction::None,
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
                // we cannot move anywhere, let's try to backtrack
                self.path
                    .pop()
                    .expect("We ran out of places to move and we cannot backtrack")
                    .reverse()
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
        let pad = 20;
        for y in ((self.position.y - pad)..(self.position.y + pad)).rev() {
            for x in (self.position.x - pad)..(self.position.x + pad) {
                if x == self.position.x && y == self.position.y {
                    print!("d");
                } else if x == 0 && y == 0 {
                    print!("X");
                } else {
                    match self.closed.get(&Point::new(x, y)) {
                        Some(v) => match *v {
                            WALL_TILE => print!("@"),
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
}

fn part1(program: Vec<i128>) -> usize {
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
                                break;
                            }
                            _ => panic!("Unknown output response {}", out),
                        }

                        if i > max_i - 10 {
                            println!("<- {:<10} {:?}", out, state);
                        }
                        //state.draw();
                    }
                    Cmd::RequestInput() => {
                        let d = state.get_next_direction();
                        state.direction = d;
                        state.position = state.position.add(state.direction.to_point());
                        if !state.is_visited(state.position) {
                            state.path.push(d);
                        }

                        robot_tx.send(Cmd::Input(d as i128)).unwrap();

                        if i > max_i - 10 {
                            println!("-> {:<10} {:?}", format!("{:?}", state.direction), state);
                        }
                    }
                    _ => panic!("Unhandled command"),
                }

                if i == max_i {
                    panic!("Quitting after {} iterations", i);
                }
            }

            state.path.len()
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
