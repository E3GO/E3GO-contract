[![Actions Status](https://github.com/vachmara/tGHP/workflows/master/badge.svg)](https://github.com/vachmara/tGHP/actions)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://github.com/prettier/prettier)
[![license](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# E³GO Solidity Project


### 📦 Installation

1. Clone this repo:
```console
git clone git@github.com:vachmara/tGHP.git
```

2. Install NPM packages:
```console
cd tGHP
npm install
```

### ⛏️ Compile

```console
npm run compile
```

This task will compile all smart contracts in the `contracts` directory.
ABI files will be automatically exported in `build/abi` directory.


### 🌡️ Testing

```console
npm run test
```

### 📊 Code coverage

```console
npm run coverage
```

The report will be printed in the console and a static website containing full report will be generated in [`coverage`](https://vachmara.github.io/tGHP/coverage) directory.


## 🐱‍💻 Verify & Publish contract source code

### Deploy contracts 
```console
npm run deploy:mainnet
```

### 🔐 Verify code

```console
npx hardhat  verify --network mainnet $CONTRACT_ADDRESS $CONSTRUCTOR_ARGUMENTS
```


## 📄 License

Apache 2.0 license. See the license file.
Anyone can use or modify this software for their purposes.