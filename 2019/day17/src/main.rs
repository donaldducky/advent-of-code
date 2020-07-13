use intcode;
use intcode::{Cmd, CPU};
use std::collections::HashMap;
use std::sync::mpsc;
use std::thread;

fn main() {
    let filename = "input.txt";
    let program = intcode::read_program(filename);

    println!("Part 1: {}", part1(&program));
}

fn part1(program: &Vec<i128>) -> u64 {
    let mut cpu = CPU::new("day17".to_string(), program.clone());

    let (cpu_tx, control_rx) = mpsc::channel();
    let (_control_tx, cpu_rx) = mpsc::channel();

    let cpu_handle = thread::Builder::new()
        .name("cpu".to_string())
        .spawn(move || {
            cpu.run(&cpu_tx, &cpu_rx);
        })
        .unwrap();

    let control_handle = thread::Builder::new()
        .name("control".to_string())
        .spawn(move || {
            let mut screen: HashMap<(u64, u64), char> = HashMap::new();
            let mut x = 0;
            let mut y = 0;

            loop {
                match control_rx.recv().unwrap() {
                    Cmd::Halt() => break,
                    Cmd::Output(out) => {
                        match (out as u8) as char {
                            '\n' => {
                                y += 1;
                                x = 0;
                            }
                            c => {
                                screen.insert((x, y), c);
                                x += 1;
                            }
                        };
                        //print!("{}", (out as u8) as char);
                    }
                    Cmd::RequestInput() => panic!("RequestInput not supported yet."),
                    _ => panic!("Unhandled command"),
                }
            }

            //println!("{:#?}", screen);
            screen
                .iter()
                .filter(|((x, y), _c)| x >= &1 && y >= &1)
                .filter(|((x, y), c)| {
                    match c {
                        '#' | '^' | '<' | '>' | 'v' => {
                            let directions: [(i64, i64); 4] = [(1, 0), (-1, 0), (0, 1), (1, 0)];

                            // look for a cross
                            directions.iter().all(|(dx, dy)| {
                                let p: (u64, u64) =
                                    ((*x as i64 + dx) as u64, (*y as i64 + dy) as u64);
                                match screen.get(&p) {
                                    None => false,
                                    Some(c2) => match c2 {
                                        '#' | '^' | '<' | '>' | 'v' => true,
                                        _ => false,
                                    },
                                }
                            })
                        }
                        _ => false,
                    }
                })
                .map(|((x, y), _c)| x * y)
                .sum()
        })
        .unwrap();

    cpu_handle.join().unwrap();
    control_handle.join().unwrap()
}
