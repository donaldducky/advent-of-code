use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let masses = input.lines()
        .map(|line| line.parse::<u32>().unwrap());

    let sum1 = masses.clone()
        .map(|mass| fuel_required(mass))
        .fold(0, |sum, fuel| sum + fuel);

    let sum2 = masses.clone()
        .map(|mass| total_fuel_required(mass, 0))
        .fold(0, |sum, fuel| sum + fuel);

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
