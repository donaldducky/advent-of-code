extern crate clap;
extern crate termion;

use clap::{Arg, Command};
use intcode;
use intcode::Cmd;
use intcode::CPU;
use std::collections::HashMap;
use std::collections::HashSet;
use std::io::{self, Write};
use std::sync::mpsc;
use std::thread;
use termion::{clear, color, cursor, style};

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
        Point { x, y }
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

struct DrawingData<'a> {
    oxygen_map: &'a mut HashSet<Point>,
    new_items: &'a mut HashSet<Point>,
    min_x: i128,
    max_x: i128,
    min_y: i128,
    max_y: i128,
}

const APP_NAME: &'static str = env!("CARGO_PKG_NAME");
const APP_VERSION: &'static str = env!("CARGO_PKG_VERSION");

fn main() {
    let app_name = format!("Advent of Code: {}", APP_NAME);
    let matches = Command::new(APP_NAME)
        .version(APP_VERSION)
        .author(env!("CARGO_PKG_AUTHORS"))
        .about(app_name)
        .arg(
            Arg::new("input-file")
                .help("input file to run against")
                .index(1)
                .default_value("input.txt"),
        )
        .arg(
            Arg::new("part-1")
                .help("Run part 1 only")
                .short('1')
                .long("1")
                .action(clap::ArgAction::SetTrue)
                .conflicts_with("part-2"),
        )
        .arg(
            Arg::new("part-2")
                .help("Run part 2 only")
                .short('2')
                .long("2")
                .action(clap::ArgAction::SetTrue)
                .conflicts_with("part-1"),
        )
        .arg(
            Arg::new("animate")
                .help("Animate steps")
                .long("animate")
                .action(clap::ArgAction::SetTrue),
        )
        .get_matches();

    let filename = matches.get_one::<String>("input-file").unwrap();
    let program = intcode::read_program(filename);

    let do_animate = matches.get_flag("animate");

    if matches.get_flag("part-1") {
        println!("{}", part1(program.clone()));
    } else if matches.get_flag("part-2") {
        println!("{}", part2(program.clone(), do_animate));
    } else {
        println!("Part 1: {}", part1(program.clone()));
        println!("Part 2: {}", part2(program.clone(), do_animate));
    }
}

fn part1(program: Vec<i128>) -> usize {
    let state = explore(program, false);

    state.path.len()
}

fn part2(program: Vec<i128>, do_animate: bool) -> usize {
    let state = explore(program, true);

    let draw_fn: &dyn Fn(&DroidState, &DrawingData) -> () =
        if do_animate { &draw_map } else { &draw_noop };

    let (min_x, max_x, min_y, max_y): (i128, i128, i128, i128) = if do_animate {
        let mut min_x: i128 = 0;
        let mut max_x: i128 = 0;
        let mut min_y: i128 = 0;
        let mut max_y: i128 = 0;

        state.closed.iter().for_each(|(p, _v)| {
            if p.x > max_x {
                max_x = p.x;
            }
            if p.x < min_x {
                min_x = p.x;
            }
            if p.y > max_y {
                max_y = p.y;
            }
            if p.y < min_y {
                min_y = p.y;
            }
        });
        (min_x, max_x, min_y, max_y)
    } else {
        (0, 0, 0, 0)
    };

    let drawing_data = DrawingData {
        oxygen_map: &mut HashSet::new(),
        new_items: &mut HashSet::new(),
        min_x,
        max_x,
        min_y,
        max_y,
    };

    if do_animate {
        print!("{}", clear::All);
        print!("{}", cursor::Hide);
        draw_fn(&state, &drawing_data);
    }

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
                drawing_data.oxygen_map.insert(p.clone());
                drawing_data.new_items.insert(p.clone());
            });
            next.extend(filtered);
        }
        open = next;

        if do_animate {
            draw_fn(&state, &drawing_data);
            drawing_data.new_items.clear();
        }

        j += 1;
    }

    if do_animate {
        let h = (max_y - min_y) as u16 + 2;
        print!("{}", cursor::Goto(1, h));
        print!("{}", cursor::Show);
    }

    // do not count initial oxygen location
    j - 1
}

fn draw_map(state: &DroidState, drawing_data: &DrawingData) {
    // better to draw on top of characters so it doesn't blink
    // This is the way.

    if drawing_data.new_items.len() > 0 {
        let w = (drawing_data.max_x - drawing_data.min_x) / 2;
        let h = (drawing_data.max_y - drawing_data.min_y) / 2;

        drawing_data.new_items.iter().for_each(|p| {
            let screen_x = (p.x + w) as u16;
            let screen_y = (p.y + h) as u16;
            print!("{}", cursor::Goto(screen_x, screen_y));
            print!("{}O{}", color::Bg(color::Blue), style::Reset);
            // stdout is line buffered, so we need to flush it
            // using println!("") also works
            io::stdout().flush().unwrap();
        });
    } else {
        let mut screen_y = 1;
        for y in drawing_data.min_y..=drawing_data.max_y {
            let mut screen_x = 1;
            for x in drawing_data.min_x..=drawing_data.max_x {
                print!("{}", cursor::Goto(screen_x, screen_y));
                let p = Point::new(x, y);
                match state.closed.get(&p) {
                    Some(v) => match *v {
                        WALL_TILE => print!("#"),
                        _ => {
                            if drawing_data.oxygen_map.contains(&p) {
                                print!("{}O{}", color::Bg(color::Blue), style::Reset)
                            } else {
                                print!(".");
                            }
                        }
                    },
                    None => print!(" "),
                }

                screen_x += 1;
            }

            screen_y += 1;
        }
    }

    std::thread::sleep(std::time::Duration::from_millis(50));
}

fn draw_noop(_state: &DroidState, _drawing_data: &DrawingData) {}

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
