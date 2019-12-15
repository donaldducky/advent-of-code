use std::fs;
use std::sync::mpsc::Sender;
use std::sync::mpsc::Receiver;

pub struct CPU {
    pub id: String,
    pub memory: Vec<i32>,
    pub ip: usize,
    debug: bool,
}

struct Instruction {
    op: Op,
    modes: Vec<Mode>,
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

enum Mode {
    Position,
    Immediate,
}

impl Instruction {
    fn mode(&self, i: usize) -> &Mode {
        match self.modes.get(i) {
            Some(mode) => mode,
            None => &Mode::Position,
        }
    }
}

impl CPU {
    pub fn new(name: String, memory: Vec<i32>) -> CPU {
        CPU {
            id: name,
            memory: memory,
            ip: 0,
            debug: false,
        }
    }

    pub fn run(&mut self, tx: &Sender<i32>, rx: &Receiver<i32>) -> i32 {
        let mut output: i32 = 0;

        loop {
            let instruction_code = self.at(self.ip);
            let ins = self.parse_instruction(instruction_code);

            match ins.op {
                Op::Add => {
                    let v1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let v2 = self.read_mode(self.ip + 2, ins.mode(1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    self.set(r, v1 + v2);
                    self.incr(4);
                },
                Op::Mul => {
                    let v1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let v2 = self.read_mode(self.ip + 2, ins.mode(1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    self.set(r, v1 * v2);
                    self.incr(4);
                },
                Op::In => {
                    let r = self.read_immediate(self.ip + 1) as usize;
                    self.print(format!("Waiting for input"));
                    let input = rx.recv().unwrap();
                    self.print(format!("Got {}", input));

                    self.set(r, input);
                    self.incr(2);
                },
                Op::Out => {
                    output = self.read_mode(self.ip + 1, ins.mode(0));
                    self.print(format!("Sending output {}", output));
                    match tx.send(output) {
                        Ok(_) => (),
                        Err(e) => {
                            self.print(format!("Send error {}", e));
                        },
                    };

                    self.incr(2);
                },
                Op::JumpTrue => {
                    let p1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let p2 = self.read_mode(self.ip + 2, ins.mode(1));

                    if p1 != 0 {
                        self.ip = p2 as usize;
                    } else {
                        self.incr(3);
                    }
                },
                Op::JumpFalse => {
                    let p1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let p2 = self.read_mode(self.ip + 2, ins.mode(1));

                    if p1 == 0 {
                        self.ip = p2 as usize;
                    } else {
                        self.incr(3);
                    }
                },
                Op::LessThan => {
                    let p1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let p2 = self.read_mode(self.ip + 2, ins.mode(1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    if p1 < p2 {
                        self.set(r, 1);
                    } else {
                        self.set(r, 0);
                    }

                    self.incr(4);
                },
                Op::Equals => {
                    let p1 = self.read_mode(self.ip + 1, ins.mode(0));
                    let p2 = self.read_mode(self.ip + 2, ins.mode(1));
                    let r = self.read_immediate(self.ip + 3) as usize;

                    if p1 == p2 {
                        self.set(r, 1);
                    } else {
                        self.set(r, 0);
                    }

                    self.incr(4);
                },
                Op::Quit => {
                    break;
                }
            };
        }

        output
    }

    fn parse_instruction(&self, instruction_code: i32) -> Instruction {
        let opcode = instruction_code % 100;
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

        let modes = (instruction_code / 100)
            .to_string()
            .chars()
            .rev()
            .map(|d| {
                match d {
                    '0' => Mode::Position,
                    '1' => Mode::Immediate,
                    _ => panic!("Unknown mode {}", d),
                }
            })
            .collect();

        Instruction {
            op: opcode,
            modes: modes,
        }
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

    fn read_mode(&self, pos: usize, mode: &Mode) -> i32 {
        match mode {
            Mode::Immediate => self.read_immediate(pos),
            _ => self.read_position(pos),
        }
    }

    fn print(&self, msg: String) {
        if self.debug {
            println!("[{}] {}", self.id, msg);
        }
    }
}

pub fn read_program(file: &str) -> Vec<i32> {
    let input = fs::read_to_string(file).unwrap();

    let int_codes: Vec<i32> = input.trim()
        .split(",")
        .map(|i| i.parse::<i32>().unwrap())
        .collect();

    int_codes
}
