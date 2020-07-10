use std::fs;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::Sender;

pub struct CPU {
    id: String,
    memory: Vec<i128>,
    ip: usize,
    debug: bool,
    relative_base: i128,
}

pub enum Cmd {
    RequestInput(),
    Input(i128),
    Output(i128),
    Halt(),
}

struct Instruction {
    op: Op,
    modes: Vec<Mode>,
}

struct Parameter {
    value: i128,
    mode: Mode,
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
    RelativeBase,
    Quit,
}

#[derive(Copy, Clone)]
enum Mode {
    Position,
    Immediate,
    Relative,
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
    pub fn new(name: String, memory: Vec<i128>) -> CPU {
        CPU {
            id: name,
            memory: memory,
            ip: 0,
            debug: false,
            relative_base: 0,
        }
    }

    pub fn debug(&mut self, is_debug: bool) {
        self.debug = is_debug;
    }

    pub fn run(&mut self, tx: &Sender<Cmd>, rx: &Receiver<Cmd>) -> i128 {
        let mut output: i128 = 0;

        loop {
            let instruction_code = self.at(self.ip);
            let ins = self.parse_instruction(instruction_code);

            match ins.op {
                Op::Add => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };
                    let p3 = Parameter {
                        value: self.at(self.ip + 3),
                        mode: *ins.mode(2),
                    };

                    self.set(self.read_pointer(p3), self.read(p1) + self.read(p2));
                    self.incr(4);
                }
                Op::Mul => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };
                    let p3 = Parameter {
                        value: self.at(self.ip + 3),
                        mode: *ins.mode(2),
                    };

                    self.set(self.read_pointer(p3), self.read(p1) * self.read(p2));
                    self.incr(4);
                }
                Op::In => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };

                    self.print(format!("Waiting for input"));

                    match tx.send(Cmd::RequestInput()) {
                        Ok(_) => (),
                        Err(e) => self.print(format!("Send error {}", e)),
                    }
                    let input = match rx.recv() {
                        Ok(cmd) => match cmd {
                            Cmd::Input(val) => val,
                            _ => panic!("Unexpected command, expected Input"),
                        },
                        Err(_) => {
                            self.print(format!("The other side probably hung up, let's halt"));
                            break;
                        }
                    };
                    self.print(format!("Got {}", input));

                    self.set(self.read_pointer(p1), input);
                    self.incr(2);
                }
                Op::Out => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    output = self.read(p1);

                    self.print(format!("Sending output {}", output));
                    match tx.send(Cmd::Output(output)) {
                        Ok(_) => (),
                        Err(e) => {
                            self.print(format!("Send error {}", e));
                        }
                    };

                    self.incr(2);
                }
                Op::JumpTrue => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };

                    if self.read(p1) != 0 {
                        self.ip = self.read(p2) as usize;
                    } else {
                        self.incr(3);
                    }
                }
                Op::JumpFalse => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };

                    if self.read(p1) == 0 {
                        self.ip = self.read(p2) as usize;
                    } else {
                        self.incr(3);
                    }
                }
                Op::LessThan => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };
                    let p3 = Parameter {
                        value: self.at(self.ip + 3),
                        mode: *ins.mode(2),
                    };

                    if self.read(p1) < self.read(p2) {
                        self.set(self.read_pointer(p3), 1);
                    } else {
                        self.set(self.read_pointer(p3), 0);
                    }

                    self.incr(4);
                }
                Op::Equals => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };
                    let p2 = Parameter {
                        value: self.at(self.ip + 2),
                        mode: *ins.mode(1),
                    };
                    let p3 = Parameter {
                        value: self.at(self.ip + 3),
                        mode: *ins.mode(2),
                    };

                    if self.read(p1) == self.read(p2) {
                        self.set(self.read_pointer(p3), 1);
                    } else {
                        self.set(self.read_pointer(p3), 0);
                    }

                    self.incr(4);
                }
                Op::RelativeBase => {
                    let p1 = Parameter {
                        value: self.at(self.ip + 1),
                        mode: *ins.mode(0),
                    };

                    self.relative_base += self.read(p1);

                    self.incr(2);
                }
                Op::Quit => {
                    match tx.send(Cmd::Halt()) {
                        Ok(_) => (),
                        Err(e) => {
                            self.print(format!("Send error when trying to halt {}", e));
                        }
                    }
                    break;
                }
            };
        }

        output
    }

    fn parse_instruction(&self, instruction_code: i128) -> Instruction {
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
            9 => Op::RelativeBase,
            99 => Op::Quit,
            _ => panic!("parse_op: unknown opcode {}", opcode),
        };

        let modes = (instruction_code / 100)
            .to_string()
            .chars()
            .rev()
            .map(|d| match d {
                '0' => Mode::Position,
                '1' => Mode::Immediate,
                '2' => Mode::Relative,
                _ => panic!("Unknown mode {}", d),
            })
            .collect();

        Instruction {
            op: opcode,
            modes: modes,
        }
    }

    fn at(&self, pos: usize) -> i128 {
        match self.memory.get(pos) {
            Some(val) => *val,
            None => 0,
        }
    }

    fn set(&mut self, pos: usize, val: i128) -> () {
        if pos >= self.memory.len() {
            self.memory.resize_with(pos + 1, Default::default);
        }
        self.memory[pos] = val;
    }

    fn incr(&mut self, n: usize) -> () {
        self.ip += n;
    }

    fn read(&self, p: Parameter) -> i128 {
        match p.mode {
            Mode::Immediate => p.value,
            _ => self.at(self.read_pointer(p)),
        }
    }

    fn read_pointer(&self, p: Parameter) -> usize {
        match p.mode {
            Mode::Position => p.value as usize,
            Mode::Immediate => panic!("Cannot read pointer in Immediate mode."),
            Mode::Relative => (p.value + self.relative_base) as usize,
        }
    }

    fn print(&self, msg: String) {
        if self.debug {
            println!("[{}] {}", self.id, msg);
        }
    }
}

pub fn read_program(file: &str) -> Vec<i128> {
    let input = fs::read_to_string(file).unwrap();

    let int_codes: Vec<i128> = input
        .trim()
        .split(",")
        .map(|i| i.parse::<i128>().unwrap())
        .collect();

    int_codes
}
