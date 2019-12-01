use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let mut sum1: u32 = 0;
    let mut sum2: u32 = 0;
    for line in input.lines() {
        let mass: u32 = line.parse().unwrap();
        sum1 += fuel_required(mass);
        sum2 += total_fuel_required(mass, 0);
    }

    println!("Fuel required for part 1: {}", sum1);
    println!("Fuel required for part 2: {}", sum2);
}

fn fuel_required(mass: u32) -> u32 {
    let fuel: i32 = (mass as i32 / 3) - 2;

    if fuel < 0 {
        0
    } else {
        fuel as u32
    }
}

fn total_fuel_required(mass: u32, sum: u32) -> u32 {
    let fuel = fuel_required(mass);

    if fuel > 0 {
        total_fuel_required(fuel, sum + fuel)
    } else {
        sum + fuel
    }
}
