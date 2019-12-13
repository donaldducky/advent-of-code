use std::cmp;
use intcode::CPU;
use intcode::read_program;

fn main() {
    let program = read_program("input.txt");

    println!("Part 1: {}", max_thruster_signal(program));

}

fn max_thruster_signal(program: Vec<i32>) -> i32 {
    let all_combinations = gen_combinations(vec![0, 1, 2, 3, 4], vec![]);
    all_combinations.iter()
        .fold(0, |acc, phase_settings| {
            cmp::max(acc, calculate_signal(program.clone(), phase_settings.clone()))
        })
}

fn calculate_signal(program: Vec<i32>, phase_settings: Vec<u8>) -> i32 {
    phase_settings.iter()
        .fold(0, |output, phase_setting| {
            let mut cpu = CPU {
                memory: program.clone(),
                ip: 0,
            };

            let inputs: Vec<isize> = vec![output as isize, *phase_setting as isize];

            cpu.run(inputs)
        })
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
