use regex::Regex;
use std::fs;
use std::collections::HashMap;
use std::collections::HashSet;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let re = Regex::new(r"(\w{3})\)(\w{3})").unwrap();

    let line_caps: Vec<regex::Captures<'_>> = input.trim()
        .lines()
        .map(|line| re.captures(line).unwrap())
        .collect();

    let mut parents = HashSet::new();
    let mut children = HashSet::new();
    let mut families: HashMap<String, HashSet<String>> = HashMap::new();
    for caps in line_caps.iter() {
        parents.insert(&caps[1]);
        children.insert(&caps[2]);
        match families.get_mut(&caps[1].to_string()) {
            Some(family) => {
                family.insert(caps[2].to_string());
            },
            None => {
                let mut children = HashSet::new();
                children.insert(caps[2].to_string());
                families.insert(caps[1].to_string(), children);
            },
        }
    }

    let mut roots: Vec<&str> = Vec::new();
    let mut orbit_count = 0;
    for (_i, x) in parents.difference(&children).enumerate() {
        roots.push(&x);
        orbit_count += count_orbits(x.to_string(), 0, &families);
    }

    println!("Part 1: {}", orbit_count);
}

// hmm rust doesn't have tail recursion
// look into trampoline / thunk?
fn count_orbits(root: String, depth: u32, families: &HashMap<String, HashSet<String>>) -> u32 {
    let count = match families.get(&root) {
        None => 0,
        Some(children) => {
            let orbits = children.iter()
                .fold(0, |sum, c| count_orbits(c.to_string(), depth + 1, &families) + sum);

            orbits
        },
    };

    count + depth
}
