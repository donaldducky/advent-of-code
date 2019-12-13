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
    let mut child_parent: HashMap<String, String> = HashMap::new();
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
        child_parent.insert(caps[2].to_string(), caps[1].to_string());
    }

    let mut roots: Vec<&str> = Vec::new();
    let mut orbit_count = 0;
    for (_i, x) in parents.difference(&children).enumerate() {
        roots.push(&x);
        orbit_count += count_orbits(x.to_string(), 0, &families);
    }

    println!("Part 1: {}", orbit_count);

    println!("Part 2: {}", count_transfers("YOU".to_string(), 0, &families, &child_parent, HashSet::new()));
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

fn count_transfers(from: String, transfers: u32, families: &HashMap<String, HashSet<String>>, child_parent: &HashMap<String, String>, visited: HashSet<String>) -> u32 {
    let mut paths: Vec<String> = Vec::new();

    match families.get(&from) {
        None => (),
        Some(children) => children.iter().for_each(|c| paths.push(c.to_string())),
    }

    match child_parent.get(&from) {
        None => (),
        Some(parent) => paths.push(parent.to_string()),
    }

    let num_transfers = paths.iter()
        .filter(|path| !visited.contains(&path.to_string()))
        .map(|path| if path == "SAN" {
            transfers - 1
        } else {
            let mut visited_paths = visited.clone();
            visited_paths.insert(from.to_string());
            count_transfers(path.to_string(), transfers + 1, &families, &child_parent, visited_paths)
        })
        .min();

    match num_transfers {
        None => 999999999,
        Some(n) => n,
    }
}
