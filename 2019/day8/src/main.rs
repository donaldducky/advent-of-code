use std::collections::HashMap;
use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let pixels: Vec<u8> = input.trim()
        .chars()
        .map(|x| x.to_digit(10).unwrap() as u8)
        .collect();

    println!("Part 1: {}", calculate_checksum(&pixels, 25, 6));
    println!("Part 2:");
    calculate_message(&pixels, 25, 6);
}

fn calculate_checksum(pixels: &Vec<u8>, width: u8, height: u8) -> u32 {
    let pixels_per_layer: usize = (width * height) as usize;
    let layers: Vec<&[u8]> = pixels.chunks(pixels_per_layer).collect();

    let min_layer = layers.iter()
        .map(|layer| {
            let mut digits_map: HashMap<u8, u8> = HashMap::new();
            layer.iter().for_each(|n| {
                let n_count = digits_map.entry(*n).or_insert(0);
                *n_count += 1;
            });
            digits_map
        })
        .min_by(|x, y| x[&0].cmp(&y[&0])).unwrap();

    (min_layer[&1] as u32) * (min_layer[&2] as u32)
}

fn calculate_message(pixels: &Vec<u8>, width: u8, height: u8) {
    let pixels_per_layer: usize = (width * height) as usize;
    let layers: Vec<&[u8]> = pixels.chunks(pixels_per_layer).collect();

    let mut image: Vec<u8> = Vec::new();

    (0..pixels_per_layer)
        .for_each(|i| {
            let pixel = layers.iter().find(|layer| layer[i] != 2).unwrap();
            image.push(pixel[i]);
        });

    let mut digits_map: HashMap<u8, u8> = HashMap::new();
    image.iter()
        .for_each(|n| {
            let n_count = digits_map.entry(*n).or_insert(0);
            *n_count += 1;
        });

    image.chunks(width as usize)
        .for_each(|row| {
            row.iter()
                .for_each(|p| {
                    let c: char;
                    if *p == 0 {
                        c = '_';
                    } else if *p == 1 {
                        c = '█';
                    } else {
                        c = ' ';
                    }
                    print!("{}", c);
                });
            println!("");
        });
}
