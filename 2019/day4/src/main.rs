use regex::Regex;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let input = input.trim();

    let re = Regex::new(r"(?P<min>\d+)-(?P<max>\d+)").unwrap();
    let caps = re.captures(input).unwrap();

    let min = &caps["min"];
    let max = &caps["max"];

    let mut cur: u32 = min.parse::<u32>().unwrap();
    let end: u32 = max.parse::<u32>().unwrap();

    let re_multiple = Regex::new(r"(00|11|22|33|44|55|66|77|88|99)").unwrap();

    let mut matches = 0;
    loop {
        if re_multiple.is_match(&cur.to_string()) {
            let mut all_increase = true;
            let mut prev: char = (b'0' - 1) as char;
            for c in cur.to_string().chars() {
                if prev > c {
                    all_increase = false;
                    break;
                }
                prev = c;
            }
            if all_increase {
                matches = matches + 1;
            }
        }

        cur = cur + 1;

        if cur == end {
            break;
        }
    }

    println!("Part 1: {}", matches);
}
