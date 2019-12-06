use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let int_codes: Vec<u32> = input.trim()
        .split(",")
        .map(|i| i.parse::<u32>().unwrap())
        .collect();

    let result_codes = run_program(int_codes.clone(), 12, 2);
    println!("Part 1: {}", result_codes.get(0).unwrap());

    let result_codes = find_inputs(int_codes, 19690720);
    let noun = result_codes[1];
    let verb = result_codes[2];
    println!("Part 2: {}", 100 * noun + verb);
}

fn run_program(mut int_codes: Vec<u32>, noun: u32, verb: u32) -> Vec<u32> {
    let mut position = 0;
    let mut opcode: u32;

    int_codes[1] = noun;
    int_codes[2] = verb;

    loop {
        opcode = *(int_codes.get(position).unwrap());

        if opcode == 99 {
            break;
        }

        let p1 = *(int_codes.get(position + 1).unwrap());
        let p2 = *(int_codes.get(position + 2).unwrap());
        let p = *(int_codes.get(position + 3).unwrap());
        let v1 = *(int_codes.get(p1 as usize).unwrap());
        let v2 = *(int_codes.get(p2 as usize).unwrap());

        let result = match opcode {
            1 => {
                v1 + v2
            },
            2 => {
                v1 * v2
            },
            _ =>
                panic!("unknown opcode"),
        };
        int_codes[p as usize] = result;
        position += 4;
    }

    int_codes
}

fn find_inputs(int_codes: Vec<u32>, result: u32) -> Vec<u32> {
    for noun in 0..100 {
        for verb in 0..100 {
            let codes = run_program(int_codes.clone(), noun, verb);
            if *(codes.get(0).unwrap()) == result {
                return codes;
            }
        }
    }

    panic!("brr");
}
