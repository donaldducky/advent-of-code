use std::collections::HashMap;
use std::sync::mpsc;
use std::thread;
use intcode;
use intcode::CPU;
use intcode::Cmd;

#[derive(Eq,PartialEq,Hash,Clone)]
struct Point {
    x: i128,
    y: i128,
}

struct Screen {
    tiles: HashMap<Point, Tile>,
    score: i128,
}

#[derive(PartialEq,Clone)]
enum Tile {
    Empty,
    Wall,
    Block,
    HorizontalPaddle,
    Ball,
}

fn main() {
    let program = intcode::read_program("input.txt");

    println!("Part 1: {}", count_block_tiles(program.clone()));
    println!("Part 2: {}", final_score(program.clone()));
}

fn count_block_tiles(program: Vec<i128>) -> usize {
    let screen = run_game(program);

    screen.tiles.iter()
        .filter(|(_, t)| **t == Tile::Block)
        .count()
}

fn final_score(mut program: Vec<i128>) -> i128 {
    program[0] = 2;
    run_game(program).score
}

fn run_game(program: Vec<i128>) -> Screen {
    let mut cpu = CPU::new("day12".to_string(), program);
    let mut score = 0;

    let (cpu_tx, game_rx) = mpsc::channel();
    let (game_tx, cpu_rx) = mpsc::channel();

    let cpu_handle = thread::spawn(move || {
        cpu.run(&cpu_tx, &cpu_rx);
    });

    let game_handle = thread::spawn(move || {
        let mut tiles: HashMap<Point, Tile> = HashMap::new();

        let mut y: i128;
        let mut tile_id: i128;

        let mut ball_position: Point = Point {x: 0, y: 0};
        let mut paddle_position: Point = Point {x: 0, y: 0};

        loop {
            match game_rx.recv().unwrap() {
                Cmd::Halt() => break,
                Cmd::Output(x) => {
                    y = match game_rx.recv().unwrap() {
                        Cmd::Output(y) => y,
                        _ => panic!("Expected Output(y)"),
                    };

                    if x == -1 && y == 0 {
                        score = match game_rx.recv().unwrap() {
                            Cmd::Output(score) => score,
                            _ => panic!("Expected Output(score)"),
                        };
                    } else {
                        tile_id = match game_rx.recv().unwrap() {
                            Cmd::Output(tile_id) => tile_id,
                            _ => panic!("Expected Output(tile_id)"),
                        };

                        let point = Point{x: x, y: y};
                        let tile = match tile_id {
                            0 => Tile::Empty,
                            1 => Tile::Wall,
                            2 => Tile::Block,
                            3 => Tile::HorizontalPaddle,
                            4 => Tile::Ball,
                            _ => panic!("Unknown tile {}", tile_id)
                        };
                        tiles.insert(point.clone(), tile.clone());

                        match tile {
                            Tile::Ball => {
                                ball_position = point.clone();
                            },
                            Tile::HorizontalPaddle => {
                                paddle_position = point.clone();
                            },
                            _ => (),
                        }
                    }
                },
                Cmd::RequestInput() => {
                    let ball_next_position = ball_position.x;
                    if ball_next_position > paddle_position.x {
                        game_tx.send(Cmd::Input(1)).unwrap();
                    } else if ball_next_position < paddle_position.x {
                        game_tx.send(Cmd::Input(-1)).unwrap();
                    } else {
                        game_tx.send(Cmd::Input(0)).unwrap();
                    }
                },
                _ => panic!("Unhandled command"),
            }
        }

        Screen {
            tiles: tiles,
            score: score,
        }
    });

    cpu_handle.join().unwrap();
    game_handle.join().unwrap()
}
