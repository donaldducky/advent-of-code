use std::fs;

fn main() {
    let filename = "input.txt";
    let input = fs::read_to_string(filename).unwrap();

    println!("Part 1: {}", part1(&input, 100, 8));
    println!("Part 2: {}", part2(&input));
}

fn part1(input: &String, num_phases: u32, num_digits: usize) -> String {
    let base_pattern: [i64; 4] = [0, 1, 0, -1];
    let mut ints = parse_input(&input);

    for _ in 0..num_phases {
        ints = ints
            .iter()
            .enumerate()
            .map(|(i, _n)| {
                let row = i + 1;
                let mut c = 0;
                let mut idx = 0;
                let sum = ints.iter().fold(0, |acc, m| {
                    c += 1;
                    if c == row {
                        idx = (idx + 1) % 4;
                        c = 0;
                    }

                    //print!("{}({}) ", m, base_pattern[idx]);

                    acc + m * base_pattern[idx]
                });

                //println!("--> sum {} = {}", sum, (sum % 10).abs());

                // take tens digit
                (sum % 10).abs()
            })
            .collect();
    }

    ints[0..num_digits]
        .iter()
        .map(|i| i.to_string())
        .collect::<Vec<String>>()
        .join("")
}

fn part2(input: &String) -> String {
    let _base_pattern: [i64; 4] = [0, 1, 0, -1];
    let ints = parse_input(&input);
    let size: usize = ints.len() * 10000;
    let mut digits: Vec<i64> = vec![0; size];

    let offset = &ints[0..7]
        .iter()
        .map(|i| i.to_string())
        .collect::<Vec<String>>()
        .join("")
        .parse::<usize>()
        .unwrap();

    // TODO: Is there a faster way to build this?
    // Looking for a way to multiply an array 10000 times was hard.
    // Either way, it doesn't take too long that it'll make the program too slow.
    let mut it = ints.iter().cycle();
    for i in 0..size {
        digits[i] = *it.next().unwrap();
    }

    // println!("ints = {:?}", ints);
    // println!("ints.len() = {}", ints.len());
    // println!("x10000 = {}", size);
    // println!("offset = {:?}", offset);

    // The way the base pattern is applied turns this into a triangular matrix.
    // 1 2 3 4 5 6 7 8 9 10        1  0 -1  0  1  0 -1  0  1  0
    //   2 3 4 5 6 7 8 9 10        0  1  1  0  0 -1 -1  0  0 -1
    //     3 4 5 6 7 8 9 10        0  0  1  1  1  0  0  0 -1 -1
    //       4 5 6 7 8 9 10        0  0  0  1  1  1  1  0  0  0
    //         5 6 7 8 9 10   =>   0  0  0  0  1  1  1  1  1  0
    //           6 7 8 9 10        0  0  0  0  0  1  1  1  1  1
    //             7 8 9 10        0  0  0  0  0  0  1  1  1  1
    //               8 9 10        0  0  0  0  0  0  0  1  1  1
    //                 9 10        0  0  0  0  0  0  0  0  1  1
    //                   10        0  0  0  0  0  0  0  0  0  1
    //
    // The offset is past the halfway point.
    // length = 6500000 and offset = 5979067
    // The only part of the base pattern we need to multiply by is 1.
    // Because of this, we can just sum the digits.

    for _i in 0..100 {
        // This is the summation of the entire row starting at the offset.
        // Each iteration can then do one subtraction, rather than summing all
        // the values again.
        let mut row_sum: i64 = digits.iter().skip(*offset).sum();
        digits.iter_mut().skip(*offset).for_each(|d| {
            let temp_sum = row_sum;
            row_sum = row_sum - *d;
            *d = (temp_sum % 10).abs();
        });
    }

    digits
        .iter()
        .skip(*offset)
        .take(8)
        .map(|i| i.to_string())
        .collect::<Vec<String>>()
        .join("")
}

fn parse_input(input: &String) -> Vec<i64> {
    input
        .trim()
        .split("")
        .filter(|i| *i != "")
        .map(|i| i.parse::<i64>().unwrap())
        .collect()
}

#[cfg(test)]
mod tests {
    use crate::part1;

    #[test]
    fn part1_example1_test() {
        let input = "12345678".to_string();
        let num_phases = 4;
        let num_digits = 8;

        assert_eq!(part1(&input, num_phases, num_digits), "01029498");
    }

    #[test]
    fn part1_example2_test() {
        let input = "80871224585914546619083218645595".to_string();
        let num_phases = 100;
        let num_digits = 8;

        assert_eq!(part1(&input, num_phases, num_digits), "24176176");
    }

    #[test]
    fn part1_example3_test() {
        let input = "19617804207202209144916044189917".to_string();
        let num_phases = 100;
        let num_digits = 8;

        assert_eq!(part1(&input, num_phases, num_digits), "73745418");
    }

    #[test]
    fn part1_example4_test() {
        let input = "69317163492948606335995924319873".to_string();
        let num_phases = 100;
        let num_digits = 8;

        assert_eq!(part1(&input, num_phases, num_digits), "52432133");
    }
}
