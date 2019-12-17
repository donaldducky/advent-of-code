use std::cmp;
use std::collections::VecDeque;
use std::thread;
use std::thread::JoinHandle;
use std::sync::mpsc;
use std::sync::mpsc::Sender;
use std::sync::mpsc::Receiver;
use intcode;
use intcode::CPU;

fn main() {
    let program = intcode::read_program("input.txt");
    println!("Part 1: {}", max_thruster_signal(program.clone(), vec![0, 1, 2, 3, 4]));
    println!("Part 2: {}", max_thruster_signal(program.clone(), vec![5, 6, 7, 8, 9]));
}

fn max_thruster_signal(program: Vec<i128>, phase_setting_values: Vec<u8>) -> i128 {
    let all_combinations = gen_combinations(phase_setting_values, vec![]);
    all_combinations.iter()
        .fold(0, |acc, phase_settings| {
            cmp::max(acc, calculate_signal(program.clone(), phase_settings.clone()))
        })
}

fn calculate_signal(program: Vec<i128>, phase_settings: Vec<u8>) -> i128 {
    let mut senders: Vec<Sender<i128>> = Vec::new();
    let mut receivers: VecDeque<Receiver<i128>> = VecDeque::new();

    phase_settings.iter()
        .for_each(|_| {
            let (tx, rx): (Sender<i128>, Receiver<i128>) = mpsc::channel();
            senders.push(tx);
            receivers.push_back(rx);
        });

    // each cpu sends to the next cpu so let's take the last receiver and put it on the front for
    // the first cpu to receive input from
    let rx = receivers.pop_back().unwrap();
    receivers.push_front(rx);

    let handles: Vec<JoinHandle<i128>> = phase_settings.iter()
        .enumerate()
        .map(|(i, _)| {
            let mut cpu = CPU::new(i.to_string(), program.clone());
            let tx = senders.get(i).unwrap();
            let tx_clone = mpsc::Sender::clone(&tx);
            let rx = receivers.pop_front().unwrap();

            thread::spawn(move || {
                cpu.run(&tx_clone, &rx)
            })
        })
        .collect();

    phase_settings.iter()
        .enumerate()
        .for_each(|(i, phase_setting)| {
            let tx = senders.get(i).unwrap();
            tx.send(*phase_setting as i128).unwrap();
        });

    // the last sender, sends to the first cpu
    let last_cpu_sender: &Sender<i128> = senders.last().unwrap();
    last_cpu_sender.send(0).unwrap();

    let mut handles = handles;
    let last_cpu_handle = handles.pop().unwrap();
    last_cpu_handle.join().unwrap()
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
