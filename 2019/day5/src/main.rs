//use regex::Regex;
use std::cmp;
use std::collections::HashSet;
use std::fs;

struct CPU {
    memory: Vec<i32>,
    ip: usize,
}

enum Op {
    Add,
    Mul,
    In,
    Out,
    JumpTrue,
    JumpFalse,
    LessThan,
    Equals,
    Quit
}

impl CPU {
    fn run(&mut self, input: isize) -> i32 {
        let mut output: i32 = 0;

        loop {
            let op = self.at(self.ip).to_string();
            let (opcode, modes) = self.parse_op(&op);
            print!("ip: {}\t", self.ip);

            match opcode {
                Op::Add => {
                    print!("[ {} {} {} {} ]\t", op, self.at(self.ip + 1), self.at(self.ip + 2), self.at(self.ip + 3));
                    let v1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let v2 = self.read_mode(self.ip + 2, modes.contains(&1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    println!("add {} {} = {} to {}", v1, v2, v1 + v2, r);
                    self.set(r, v1 + v2);
                    self.incr(4);
                },
                Op::Mul => {
                    print!("[ {} {} {} {} ]\t", op, self.at(self.ip + 1), self.at(self.ip + 2), self.at(self.ip + 3));
                    let v1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let v2 = self.read_mode(self.ip + 2, modes.contains(&1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    println!("mul {} {} = {} to {}", v1, v2, v1 * v2, r);
                    self.set(r, v1 * v2);
                    self.incr(4);
                },
                Op::In => {
                    print!("[ {} {} ]\t", op, self.at(self.ip + 1));
                    let r = self.read_immediate(self.ip + 1) as usize;

                    println!("in {} to {}", input, r);
                    self.set(r, input as i32);
                    self.incr(2);
                },
                Op::Out => {
                    print!("[ {} {} ]\t", op, self.at(self.ip + 1));
                    output = self.read_mode(self.ip + 1, modes.contains(&0));

                    println!("out {}", output);
                    self.incr(2);
                },
                Op::JumpTrue => {
                    let p1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let p2 = self.read_mode(self.ip + 2, modes.contains(&1));

                    println!("jumptrue");
                    if p1 != 0 {
                        self.ip = p2 as usize;
                    } else {
                        self.incr(3);
                    }
                },
                Op::JumpFalse => {
                    let p1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let p2 = self.read_mode(self.ip + 2, modes.contains(&1));

                    println!("jumpfalse");
                    if p1 == 0 {
                        self.ip = p2 as usize;
                    } else {
                        self.incr(3);
                    }
                },
                Op::LessThan => {
                    let p1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let p2 = self.read_mode(self.ip + 2, modes.contains(&1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    println!("lessthan");
                    if p1 < p2 {
                        self.set(r, 1);
                    } else {
                        self.set(r, 0);
                    }

                    self.incr(4);
                },
                Op::Equals => {
                    let p1 = self.read_mode(self.ip + 1, modes.contains(&0));
                    let p2 = self.read_mode(self.ip + 2, modes.contains(&1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    println!("equals");
                    if p1 == p2 {
                        self.set(r, 1);
                    } else {
                        self.set(r, 0);
                    }

                    self.incr(4);
                },
                Op::Quit => {
                    println!("] quit");
                    break;
                }
            };
        }

        output
    }

    fn parse_op(&self, op: &String) -> (Op, HashSet<usize>) {
        let len = op.len();

        let op_start = cmp::max(0, len as i32 - 2) as usize;
        let opcode = &op[op_start..];
        let opcode = opcode.parse::<u32>().unwrap();
        let opcode = match opcode {
            1 => Op::Add,
            2 => Op::Mul,
            3 => Op::In,
            4 => Op::Out,
            5 => Op::JumpTrue,
            6 => Op::JumpFalse,
            7 => Op::LessThan,
            8 => Op::Equals,
            99 => Op::Quit,
            _ => panic!("parse_op: unknown opcode {}", opcode)
        };

        let modes_end = cmp::max(0, len as i32 - 2) as usize;
        let mode_string = &op[0..modes_end];
        let mut modes = HashSet::new();
        for (i, c) in (*mode_string).chars().rev().enumerate() {
            match c {
                '1' => {
                    modes.insert(i);
                },
                _ => (),
            }
        }

        (opcode, modes)
    }

    fn at(&self, pos: usize) -> i32 {
        *(self.memory.get(pos).unwrap())
    }

    fn set(&mut self, pos: usize, val: i32) -> () {
        self.memory[pos] = val;
    }

    fn incr(&mut self, n: usize) -> () {
        self.ip += n;
    }

    fn read_position(&self, pos: usize) -> i32 {
        self.at(self.at(pos) as usize)
    }

    fn read_immediate(&self, pos: usize) -> i32 {
        self.at(pos)
    }

    fn read_mode(&self, pos: usize, is_immediate: bool) -> i32 {
        match is_immediate {
            true => self.read_immediate(pos),
            false => self.read_position(pos),
        }
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let int_codes: Vec<i32> = input.trim()
        .split(",")
        .map(|i| i.parse::<i32>().unwrap())
        .collect();

    let mut cpu = CPU {
        memory: int_codes.clone(),
        ip: 0
    };

    println!("Part 1: {}", cpu.run(1));

    let mut cpu = CPU {
        memory: int_codes.clone(),
        ip: 0
    };
    println!("Part 2: {}", cpu.run(5));
}
