# Functional tests 
Tests are conducted on the Kovan test network. The following contracts has been verified on Etherscan. 
  
## [`MultiSigWallet[0xcf8e14]`](https://kovan.etherscan.io/address/0xcf8e140c636983b734ff8eca20f2ddac8a6e2928#code)
## [`Ace[0x4ed11a]`](https://kovan.etherscan.io/address/0x4ed11a3ebd78ee62d613f5cac04ce2a6b254f32f#code) 
 
  
## Accounts 
  
* Owner1: [0x006F3FCdDaf248D1a4C9A7fd62939963AAAe5a67](https://kovan.etherscan.io/address/0x006F3FCdDaf248D1a4C9A7fd62939963AAAe5a67)
* Owner2: [0x7e691f8bd61731043725fbfd36bd6e9b0c261fb2](https://kovan.etherscan.io/address/0x7e691f8bd61731043725fbfd36bd6e9b0c261fb2) 
  
## Expected behaviour test of MultiSigWallet 
- [x] Submit transaction by a owner.[0xe6566c](https://kovan.etherscan.io/tx/0xe6566ccb438b9e7338f5b865c3c1bc72ac9184c77ce02a6e15236a32e8819bfe)
- [x] Create Ace token contract.[0xe6566c](https://kovan.etherscan.io/tx/0xe6566ccb438b9e7338f5b865c3c1bc72ac9184c77ce02a6e15236a32e8819bfe#internal) 

## Expected behaviour tests of Ace 
- [x] Selling can be turned off only by the owner.[0x89e7de](https://kovan.etherscan.io/tx/0x89e7de04a10b6ee531f11e0dd1d4c7aac2a728d451f3e5d17d1fd1ccf3b6f6d2)
- [x] Selling can be turned on only by the owner.[0xede820](https://kovan.etherscan.io/tx/0xede8201f1502dc4bd857fd059d07226a7bd5b3a8d392c2f2a5162cf53dc910e4)
- [x] Minimum buy can be set only by the owner. [0x1d68ac](https://kovan.etherscan.io/tx/0x1d68ac85612ee1d058c70710bdbca64c06326133fbf0faafb1b8380a6d90e202)
- [x] ICO percent can be set only by the owner. [0x51c5c4](https://kovan.etherscan.io/tx/0x51c5c48c9f74fd8d1c362053d9e4f07f2f14b3806df4fc8db4ce2be9c48099c6)
- [x] Only the owner can turn on token tradable. [0xf99531](https://kovan.etherscan.io/tx/0xf995311192ea60f361365eab16053eb0b5083c5b37568ce8edf1ba78028d22e1)
- [x] Buy price can be set only by the owner. [0xc3da9b](https://kovan.etherscan.io/tx/0xc3da9b08df1043a855e25cec7636b32915fd08401297118f95c4f8c9d4c9baab)
- [x] Investors can be added only by the owner. [0x6bdbb1](https://kovan.etherscan.io/tx/0x6bdbb1756eb38f0ee12b20b51aee64403feddbe007c2f783cf887144b794a247)
- [x] Maximum burn can be set only by the owner.[0x09eb99](https://kovan.etherscan.io/tx/0x09eb9966c4688f9834a39ff5abe48d4c00143df50d6c8db40221bb9264bbc4c4)
- [x] Valid investor can purchase Ace tokens. [0x9ba204](https://kovan.etherscan.io/tx/0x9ba204f3e0877bd53831c16b4fb590c3503e46dcbbaf86bf781257dee5318545)
- [x] Only owner can withdraw all the ethers in the Ace contract. [0xd39f01](https://kovan.etherscan.io/tx/0xd39f01cc2fdc5b0bc9d7e75c3a04fdda28009079975bea976067d473a3e67b93)
- [x] Maximum buy can be set only by the owner. [0x2a263c](https://kovan.etherscan.io/tx/0x2a263cbbe8b442098893fc77200dab39e52085645d1a05421844b3181f0ecc9c)
- [x] Tokens can be transfered to other address. [0xda9bf2](https://kovan.etherscan.io/tx/0xda9bf2dba37f6a204d1523e8637b00d03d0595657e4dac3a068afd1c7887ac74)
- [x] Allowance can be set by calling `approve()`. [0x15da61](https://kovan.etherscan.io/tx/0x15da61a2d40640ff13ab9e854e1c08dc268b8731e46a1f8021f0062f310b4902) 
- [x] Spender can get tokens by calling `transferFrom()` if only allowance is enough. [0xfdb062](https://kovan.etherscan.io/tx/0xfdb062cf1d750c3363db1cbc9c0291fa1c0e43197387756df0c7dcb33ef9602d)
- [x] Investors can be removed only by the owner. [0x575095](https://kovan.etherscan.io/tx/0x575095877699a732ee40bb692f4e4b1ac052d88338f6bc53f39f90a0218b3e4c)
- [x] Tokens can be burned only by the owner. [0x187eb0](https://kovan.etherscan.io/tx/0x187eb0da91a822b391ff5974bb7cd517c89517d1ce0b1e360ad1cc572f2c778b)
