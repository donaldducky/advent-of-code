use std::sync::mpsc;
use std::thread;
use intcode;

fn main() {
    let program = intcode::read_program("input.txt");

    println!("Part 1: {}", boost_keycode(program.clone(), 1));
    println!("Part 2: {}", boost_keycode(program.clone(), 2));
}

fn boost_keycode(program: Vec<i128>, input: i128) -> i128 {
    let mut cpu = intcode::CPU::new("day9".to_string(), program.clone());

    let (tx, rx) = mpsc::channel();
    let tx0 = mpsc::Sender::clone(&tx);

    let handle = thread::spawn(move || {
        cpu.run(&tx0, &rx)
    });

    tx.send(input).unwrap();

    handle.join().unwrap()
}
