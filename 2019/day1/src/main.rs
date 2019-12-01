use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let mut sum: u32 = 0;
    for line in input.lines() {
        let mass: u32 = line.parse().unwrap();
        sum += fuel_required(mass);
    }

    println!("Fuel required: {}", sum);
}

fn fuel_required(mass: u32) -> u32 {
    (mass / 3) - 2
}
