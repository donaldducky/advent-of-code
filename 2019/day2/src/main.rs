use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let mut int_codes: Vec<u32> = input.trim()
        .split(",")
        .map(|i| i.parse::<u32>().unwrap())
        .collect();

    int_codes[1] = 12;
    int_codes[2] = 2;
    int_codes = run_program(int_codes);

    println!("Part 1: {}", int_codes.get(0).unwrap());
}

fn run_program(mut int_codes: Vec<u32>) -> Vec<u32> {
    let mut position = 0;
    let mut opcode: u32;

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
