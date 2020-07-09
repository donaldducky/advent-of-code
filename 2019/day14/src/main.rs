use itertools::Itertools;
use std::collections::HashMap;
use std::fmt;
use std::fs;

#[derive(Debug, Eq, PartialEq, Hash, Clone)]
struct Chemical {
    id: String,
    quantity: u64,
}

#[derive(Debug, Eq, PartialEq, Hash, Clone)]
struct Reaction {
    input_chemicals: Vec<Chemical>,
    output_chemical: Chemical,
}

impl Chemical {
    fn new(id: String, quantity: u64) -> Chemical {
        Chemical {
            id: id,
            quantity: quantity,
        }
    }
}

impl fmt::Display for Chemical {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}({})", self.id, self.quantity)
    }
}

impl Reaction {
    fn new(inputs: Vec<Chemical>, output: Chemical) -> Reaction {
        Reaction {
            input_chemicals: inputs,
            output_chemical: output,
        }
    }
}

impl fmt::Display for Reaction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "{} => {}",
            self.input_chemicals.iter().format(" "),
            self.output_chemical
        )
    }
}

fn main() {
    let input = read_file("input.txt");

    println!("Part 1: {}", calculate_ore_required(input.clone(), 1));
    println!("Part 1: {}", calculate_maximum_fuel(input.clone()));
}

fn read_file(file: &str) -> String {
    fs::read_to_string(file).unwrap()
}

fn parse_reactions(input: String) -> Vec<Reaction> {
    let reactions: Vec<Reaction> = input
        .trim()
        .split("\n")
        .map(|line| {
            let parts: Vec<&str> = line.split(" => ").collect();
            if parts.len() != 2 {
                panic!("Could not parse line {}", line)
            }
            let inputs: Vec<Chemical> = parts[0]
                .split(", ")
                .map(|chemical| parse_chemical(chemical))
                .collect();

            let output = parse_chemical(parts[1]);

            Reaction::new(inputs, output)
        })
        .collect();

    reactions
}

fn parse_chemical(chemical: &str) -> Chemical {
    let parts: Vec<&str> = chemical.split(" ").collect();
    if parts.len() != 2 {
        panic!("Could not parse chemical from {}", chemical)
    }

    let qty = parts[0].parse::<u64>().unwrap();
    let id = parts[1];

    Chemical::new(id.to_string(), qty)
}

fn calculate_ore_required(input: String, num_fuel: u64) -> u64 {
    let reactions = parse_reactions(input);

    // convert to HashMap so we can easily look up reactions by output
    // TODO should have read it as a HashMap to begin with
    let reactions_by_output: HashMap<String, Reaction> =
        reactions.into_iter().fold(HashMap::new(), |mut acc, r| {
            acc.insert(r.output_chemical.id.to_string(), r);
            acc
        });

    let mut chemicals_needed: Vec<Chemical> = vec![Chemical::new("FUEL".to_string(), num_fuel)];
    let mut extra: HashMap<String, u64> = HashMap::new();
    let mut ores: u64 = 0;

    while chemicals_needed.len() > 0 {
        let c = chemicals_needed.pop().unwrap();
        let r = reactions_by_output.get(&c.id).unwrap();

        // find out how many "extras" we have
        let extras = match extra.get(&c.id) {
            Some(n) => *n,
            None => 0,
        };
        if extras >= c.quantity {
            extra.insert(c.id, extras - c.quantity);
            continue;
        }

        let ores_per_reaction = r.input_chemicals[0].quantity;
        let quantity_per_reaction = r.output_chemical.quantity;

        let quantity_needed = c.quantity - extras;

        let mut reactions_needed = quantity_needed / quantity_per_reaction;
        if quantity_needed % quantity_per_reaction > 0 {
            reactions_needed += 1;
        }

        let quantity_created = quantity_per_reaction * reactions_needed;
        extra.insert(c.id, quantity_created - quantity_needed);

        if r.input_chemicals.len() == 1 && r.input_chemicals[0].id == "ORE" {
            ores += ores_per_reaction * reactions_needed;
        } else {
            let mut chemicals_to_append = r.input_chemicals.clone();
            chemicals_to_append
                .iter_mut()
                .for_each(|c| c.quantity *= reactions_needed);

            chemicals_needed.append(&mut chemicals_to_append);
        }
    }

    ores
}

fn calculate_maximum_fuel(input: String) -> u64 {
    // we need at least this much (due to extra chemicals being accumulated)
    let ores_available: u64 = 1e12 as u64;
    let mut min = ores_available / calculate_ore_required(input.clone(), 1);
    let mut max = min;

    // calculate some upper bound
    while calculate_ore_required(input.clone(), max) < ores_available {
        min = max;
        max *= 10;
    }

    // do a binary search
    loop {
        let mid = min + (max - min) / 2;

        if min == mid {
            break;
        }

        let ores = calculate_ore_required(input.clone(), mid);

        if ores >= ores_available {
            max = mid;
        } else if ores < ores_available {
            min = mid;
        }
    }

    min
}

#[cfg(test)]
mod tests {
    use crate::calculate_maximum_fuel;
    use crate::calculate_ore_required;

    /**
     * TODO figure out how to do table tests
     * - one method is to use macros: https://stackoverflow.com/a/34666891
     * - another option is table-test: https://github.com/nathanielsimard/table-test
     */
    #[test]
    fn example_1() {
        let input = "\
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL"
            .to_string();

        assert_eq!(calculate_ore_required(input, 1), 31);
    }

    #[test]
    fn example_2() {
        let input = "\
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL"
            .to_string();

        assert_eq!(calculate_ore_required(input, 1), 165);
    }

    #[test]
    fn example_3() {
        let input = "\
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
            .to_string();

        assert_eq!(calculate_ore_required(input, 1), 13312);
    }

    #[test]
    fn example_4() {
        let input = "\
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF"
            .to_string();

        assert_eq!(calculate_ore_required(input, 1), 180697);
    }

    #[test]
    fn example_5() {
        let input = "\
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX"
            .to_string();

        assert_eq!(calculate_ore_required(input, 1), 2210736);
    }

    #[test]
    fn example_6() {
        let input = "\
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
            .to_string();

        assert_eq!(calculate_maximum_fuel(input), 82892753);
    }

    #[test]
    fn example_7() {
        let input = "\
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF"
            .to_string();

        assert_eq!(calculate_maximum_fuel(input), 5586022);
    }

    #[test]
    fn example_8() {
        let input = "\
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX"
            .to_string();

        assert_eq!(calculate_maximum_fuel(input), 460664);
    }
}
