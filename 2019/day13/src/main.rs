use std::collections::HashMap;
use std::sync::mpsc;
use std::thread;
use intcode;
use intcode::CPU;

#[derive(Eq,PartialEq,Hash)]
struct Point {
    x: i128,
    y: i128,
}

struct Screen {
    tiles: HashMap<Point, Tile>,
}

#[derive(PartialEq)]
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
}

fn count_block_tiles(program: Vec<i128>) -> usize {
    let screen = run_game(program);

    screen.tiles.iter()
        .filter(|(_, t)| **t == Tile::Block)
        .count()
}

fn run_game(program: Vec<i128>) -> Screen {
    let mut cpu = CPU::new("day12".to_string(), program);

    let (cpu_tx, game_rx) = mpsc::channel();
    let (_game_tx, cpu_rx) = mpsc::channel();
    let cpu_tx_copy = mpsc::Sender::clone(&cpu_tx);

    let cpu_handle = thread::spawn(move || {
        cpu.run(&cpu_tx, &cpu_rx);
    });

    let game_handle = thread::spawn(move || {
        let mut tiles: HashMap<Point, Tile> = HashMap::new();

        let mut x: i128;
        let mut y: i128;
        let mut tile_id: i128;

        loop {
            x = game_rx.recv().unwrap();
            if x == -1 {
                break;
            }

            y = game_rx.recv().unwrap();
            tile_id = game_rx.recv().unwrap();

            let point = Point{x: x, y: y};
            let tile = match tile_id {
                0 => Tile::Empty,
                1 => Tile::Wall,
                2 => Tile::Block,
                3 => Tile::HorizontalPaddle,
                4 => Tile::Ball,
                _ => panic!("Unknown tile {}", tile_id)
            };
            tiles.insert(point, tile);
        }

        tiles
    });

    cpu_handle.join().unwrap();
    // TODO better way to send halt signal
    cpu_tx_copy.send(-1).unwrap();
    let tiles = game_handle.join().unwrap();

    Screen {
        tiles: tiles
    }
}
