use std::collections::HashMap;
use std::collections::HashSet;
use std::sync::mpsc;
use std::thread;
use intcode;

#[derive(Eq,PartialEq,Hash,Copy,Clone)]
struct Point {
    x: i32,
    y: i32,
}

enum Color {
    Black,
    White,
}

enum Direction {
    Up,
    Down,
    Left,
    Right,
}

fn main() {
    let program = intcode::read_program("input.txt");

    println!("Part 1: {}", panels_painted(program.clone()));
    println!("Part 2:");
    draw_registration(program.clone());
}

fn panels_painted(program: Vec<i128>) -> usize {
    let mut cpu = intcode::CPU::new("day11".to_string(), program);

    let (cpu_tx, robot_rx) = mpsc::channel();
    let (robot_tx, cpu_rx) = mpsc::channel();
    let cpu_tx_copy = mpsc::Sender::clone(&cpu_tx);

    let cpu_handle = thread::spawn(move || {
        cpu.run(&cpu_tx, &cpu_rx)
    });

    let robot_handle = thread::spawn(move || {
        let mut panels: HashMap<Point, Color> = HashMap::new();
        let mut painted: HashSet<Point> = HashSet::new();
        let mut position = Point{x: 0, y: 0};
        let mut direction = Direction::Up;

        let mut out1: Color;
        let mut out2: Direction;

        loop {
            // inputs:
            //   0 if over black panel
            //   1 if over white panel
            let color = match panels.get(&position) {
                Some(color) => color,
                None => &Color::Black,
            };

            let input = match color {
                Color::Black => 0,
                Color::White => 1,
            };

            robot_tx.send(input).unwrap();

            // outputs:
            //  output[0] color to paint (0 black, 1 white)
            //  output[1] direction to turn (0 turn left, 1 turn right)
            out1 = match robot_rx.recv().unwrap() {
                0 => Color::Black,
                1 => Color::White,
                -1 => break,
                output => panic!("Unknown robot out1 {}", output),
            };

            // paint
            let panel = panels.entry(position).or_insert(Color::Black);
            *panel = out1;
            painted.insert(position);

            out2 = match robot_rx.recv().unwrap() {
                0 => Direction::Left,
                1 => Direction::Right,
                output => panic!("Unknown robot out2 {}", output),
            };

            // turn
            direction = change_direction(&direction, &out2);

            // move
            position = move_forward(&position, &direction);
        };

        painted.len()
    });

    cpu_handle.join().unwrap();
    // TODO better way to send halt signal
    cpu_tx_copy.send(-1).unwrap();
    robot_handle.join().unwrap()
}

fn draw_registration(program: Vec<i128>) {
    let mut cpu = intcode::CPU::new("day11".to_string(), program);

    let (cpu_tx, robot_rx) = mpsc::channel();
    let (robot_tx, cpu_rx) = mpsc::channel();
    let cpu_tx_copy = mpsc::Sender::clone(&cpu_tx);

    let cpu_handle = thread::spawn(move || {
        cpu.run(&cpu_tx, &cpu_rx)
    });

    let robot_handle = thread::spawn(move || {
        let mut panels: HashMap<Point, Color> = HashMap::new();
        panels.insert(Point{x: 0, y: 0}, Color::White);
        let mut painted: HashSet<Point> = HashSet::new();
        let mut position = Point{x: 0, y: 0};
        let mut direction = Direction::Up;

        let mut out1: Color;
        let mut out2: Direction;

        loop {
            // inputs:
            //   0 if over black panel
            //   1 if over white panel
            let color = match panels.get(&position) {
                Some(color) => color,
                None => &Color::Black,
            };

            let input = match color {
                Color::Black => 0,
                Color::White => 1,
            };

            robot_tx.send(input).unwrap();

            // outputs:
            //  output[0] color to paint (0 black, 1 white)
            //  output[1] direction to turn (0 turn left, 1 turn right)
            out1 = match robot_rx.recv().unwrap() {
                0 => Color::Black,
                1 => Color::White,
                -1 => break,
                output => panic!("Unknown robot out1 {}", output),
            };

            // paint
            let panel = panels.entry(position).or_insert(Color::Black);
            *panel = out1;
            painted.insert(position);

            out2 = match robot_rx.recv().unwrap() {
                0 => Direction::Left,
                1 => Direction::Right,
                output => panic!("Unknown robot out2 {}", output),
            };

            // turn
            direction = change_direction(&direction, &out2);

            // move
            position = move_forward(&position, &direction);
        };

        panels
    });

    cpu_handle.join().unwrap();
    // TODO better way to send halt signal
    cpu_tx_copy.send(-1).unwrap();
    let panels = robot_handle.join().unwrap();

    let xs = panels.iter().map(|(p, _)| p.x);
    let min_x = xs.clone().min().unwrap();
    let max_x = xs.clone().max().unwrap();
    let ys = panels.iter().map(|(p, _)| p.y);
    let min_y = ys.clone().min().unwrap();
    let max_y = ys.clone().max().unwrap();

    for y in min_y..(max_y+1) {
        for x in min_x..(max_x+1) {
            let c = match panels.get(&Point{x: x, y: y}) {
                Some(color) => color,
                None => &Color::Black,
            };

            match c {
                Color::White => print!("#"),
                Color::Black => print!(" "),
            };
        }
        println!("");
    }
}

fn change_direction(current: &Direction, turn: &Direction) -> Direction {
    match turn {
        Direction::Left => {
            match current {
                Direction::Up => Direction::Left,
                Direction::Down => Direction::Right,
                Direction::Left => Direction::Down,
                Direction::Right => Direction::Up,
            }
        },
        Direction::Right => {
            match current {
                Direction::Up => Direction::Right,
                Direction::Down => Direction::Left,
                Direction::Left => Direction::Up,
                Direction::Right => Direction::Down,
            }
        },
        _ => panic!("Unsupported direction change"),
    }
}

fn move_forward(position: &Point, direction: &Direction) -> Point {
    let delta = match direction {
        Direction::Up => Point{x: 0, y: -1},
        Direction::Down => Point{x: 0, y: 1},
        Direction::Left => Point{x: -1, y: 0},
        Direction::Right => Point{x: 1, y: 0},
    };

    Point{
        x: position.x + delta.x,
        y: position.y + delta.y,
    }
}
