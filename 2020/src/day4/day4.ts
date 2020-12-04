import * as fs from 'fs';
import * as path from 'path';

const passports = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n\n')
  .map(line =>
    // array of key/value pairs
    // [['byr', 2002], ['iyr', 2020], ...]
    line.split(/[\n ]/).map(field => field.split(':'))
  )
  .map(Object.fromEntries);

console.log('Part 1:', passports.filter(isValid).length);
console.log('Part 2:', passports.filter(isValid).filter(isValid2).length);

function isValid(passport) {
  return ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'].every(
    k =>
      // had to rewrite this for eslint because of no-prototype-builtins
      // https://eslint.org/docs/rules/no-prototype-builtins
      // passport.hasOwnProperty(k)
      //passport[k] ?? false
      //Object.prototype.hasOwnProperty.call(passport, k)
      k in passport
  );
}

function isValid2(passport) {
  if (!(+passport.byr >= 1920 && +passport.byr <= 2002)) {
    return false;
  }
  if (!(+passport.iyr >= 2010 && +passport.iyr <= 2020)) {
    return false;
  }
  if (!(+passport.eyr >= 2020 && +passport.eyr <= 2030)) {
    return false;
  }
  if (passport.hgt.match(/\d+cm/)) {
    const hgt = +passport.hgt.split('cm')[0];
    if (!(hgt >= 150 && hgt <= 193)) {
      return false;
    }
  } else if (passport.hgt.match(/\d+in/)) {
    const hgt = +passport.hgt.split('in')[0];
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
