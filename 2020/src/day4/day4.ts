import * as fs from 'fs';
import * as path from 'path';

const lines = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n');

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines): number {
  let currentPassport = {};

  let validPassports = lines.reduce((count, line) => {
    if (line == '') {
      if (isValid(currentPassport)) {
        count++;
      }
      currentPassport = {};
    } else {
      currentPassport = line.split(' ').reduce((passport, l) => {
        const [k, v] = l.split(':');

        passport[k] = v;

        return passport;
      }, currentPassport);
    }

    return count;
  }, 0);

  if (isValid(currentPassport)) {
    validPassports++;
  }

  return validPassports;
}

function part2(lines) {
  let currentPassport = {};

  let validPassports = lines.reduce((count, line) => {
    if (line == '') {
      if (isValid2(currentPassport)) {
        count++;
      }
      currentPassport = {};
    } else {
      currentPassport = line.split(' ').reduce((passport, l) => {
        const [k, v] = l.split(':');

        passport[k] = v;

        return passport;
      }, currentPassport);
    }

    return count;
  }, 0);

  if (isValid2(currentPassport)) {
    validPassports++;
  }

  return validPassports;
}

function isValid(passport) {
  return ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'].every(k =>
    passport.hasOwnProperty(k)
  );
}

function isValid2(passport) {
  if (!isValid(passport)) {
    return false;
  }

  const byr = parseInt(passport.byr, 10);
  if (!(byr >= 1920 && byr <= 2002)) {
    return false;
  }
  const iyr = parseInt(passport.iyr, 10);
  if (!(iyr >= 2010 && iyr <= 2020)) {
    return false;
  }
  const eyr = parseInt(passport.eyr, 10);
  if (!(eyr >= 2020 && eyr <= 2030)) {
    return false;
  }
  if (passport.hgt.match(/\d+cm/)) {
    const hgt = parseInt(passport.hgt.split('cm')[0], 10);
    if (!(hgt >= 150 && hgt <= 193)) {
      return false;
    }
  } else if (passport.hgt.match(/\d+in/)) {
    const hgt = parseInt(passport.hgt.split('in')[0], 10);
    if (!(hgt >= 59 && hgt <= 76)) {
      return false;
    }
  } else {
    return false;
  }
  if (!passport.hcl.match(/#[0-9a-f]{6}/)) {
    return false;
  }
  if (
    !['amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'].includes(passport.ecl)
  ) {
    return false;
  }
  if (!passport.pid.match(/^[0-9]{9}$/)) {
    return false;
  }

  return true;
}
