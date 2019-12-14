use std::cmp;
use std::thread;
use std::sync::mpsc;
use std::sync::mpsc::Sender;
use std::sync::mpsc::Receiver;
use intcode::CPU;
use intcode::read_program;

fn main() {
    let program = read_program("input.txt");
    println!("Part 1: {}", max_thruster_signal(program.clone()));
    println!("Part 2: {}", max_thruster_signal2(program.clone()));
}

fn max_thruster_signal(program: Vec<i32>) -> i32 {
    let all_combinations = gen_combinations(vec![0, 1, 2, 3, 4], vec![]);
    all_combinations.iter()
        .fold(0, |acc, phase_settings| {
            cmp::max(acc, calculate_signal(program.clone(), phase_settings.clone()))
        })
}

fn max_thruster_signal2(program: Vec<i32>) -> i32 {
    let all_combinations = gen_combinations(vec![5, 6, 7, 8, 9], vec![]);
    all_combinations.iter()
        .fold(0, |acc, phase_settings| {
            cmp::max(acc, calculate_signal2(program.clone(), phase_settings.clone()))
        })
}

fn calculate_signal(program: Vec<i32>, phase_settings: Vec<u8>) -> i32 {
    phase_settings.iter()
        .fold(0, |output, phase_setting| {
            let mut cpu = CPU::new(phase_setting.to_string(), program.clone());

            let inputs: Vec<isize> = vec![output as isize, *phase_setting as isize];

            cpu.run(inputs)
        })
}

fn calculate_signal2(program: Vec<i32>, phase_settings: Vec<u8>) -> i32 {
    let (tx0, rx0): (Sender<i32>, Receiver<i32>) = mpsc::channel();
    let (tx1, rx1): (Sender<i32>, Receiver<i32>) = mpsc::channel();
    let (tx2, rx2): (Sender<i32>, Receiver<i32>) = mpsc::channel();
    let (tx3, rx3): (Sender<i32>, Receiver<i32>) = mpsc::channel();
    let (tx4, rx4): (Sender<i32>, Receiver<i32>) = mpsc::channel();

    let mut cpu0 = CPU::new("A".to_string(), program.clone());
    let tx0_clone = mpsc::Sender::clone(&tx0);
    let handle0 = thread::spawn(move || {
        cpu0.run2(&tx0_clone, &rx4)
    });

    let mut cpu1 = CPU::new("B".to_string(), program.clone());
    let tx1_clone = mpsc::Sender::clone(&tx1);
    let handle1 = thread::spawn(move || {
        cpu1.run2(&tx1_clone, &rx0)
    });

    let mut cpu2 = CPU::new("C".to_string(), program.clone());
    let tx2_clone = mpsc::Sender::clone(&tx2);
    let handle2 = thread::spawn(move || {
        cpu2.run2(&tx2_clone, &rx1)
    });

    let mut cpu3 = CPU::new("D".to_string(), program.clone());
    let tx3_clone = mpsc::Sender::clone(&tx3);
    let handle3 = thread::spawn(move || {
        cpu3.run2(&tx3_clone, &rx2)
    });

    let mut cpu4 = CPU::new("E".to_string(), program.clone());
    let tx4_clone = mpsc::Sender::clone(&tx4);
    let handle4 = thread::spawn(move || {
        cpu4.run2(&tx4_clone, &rx3)
    });

    tx4.send(*(phase_settings.get(0).unwrap()) as i32).unwrap();
    tx0.send(*(phase_settings.get(1).unwrap()) as i32).unwrap();
    tx1.send(*(phase_settings.get(2).unwrap()) as i32).unwrap();
    tx2.send(*(phase_settings.get(3).unwrap()) as i32).unwrap();
    tx3.send(*(phase_settings.get(4).unwrap()) as i32).unwrap();
    tx4.send(0).unwrap();

    handle0.join().unwrap();
    handle1.join().unwrap();
    handle2.join().unwrap();
    handle3.join().unwrap();
    handle4.join().unwrap()
}

fn gen_combinations(settings: Vec<u8>, current: Vec<u8>) -> Vec<Vec<u8>> {
    let mut all: Vec<Vec<u8>> = Vec::new();
    let len = settings.len();

    for i in 0..len {
        let mut current = current.clone();
        let mut remaining: Vec<u8> = Vec::new();
        for j in 0..len {
            if i == j {
                current.push(*settings.get(i).unwrap());
            } else {
                remaining.push(*settings.get(j).unwrap());
            }
        }
        if remaining.len() == 0 {
            all.push(current);
        } else {
            for j in  gen_combinations(remaining, current).iter() {
                all.push(j.clone());
            }
        }
    }

    all
}
