# Dynamic Analysis
Performed by Blockchain Labs, 20 Sep, 2018

```
 Contract: Ace
    √ The owner can turn off and on the sale (547ms)
    √ A vandal can't turn off or on the sale (352ms)
    √ The owner can set the buy price (258ms)
    √ The owner can't set the buy price to 0 (300ms)
    √ Can't transfer tokens to address(0) (300ms)
    √ Total supply should be reduced when tokens are burned (331ms)
    √ Investors can purchase Ace Tokens if whitelisted (911ms)
    √ Investors can't purchase Ace Tokens if not whitelisted (383ms)
    √ The owner can set IcoPercent but a vandal can't (340ms)
    √ The owner can set minimum buy but a vandal can't (372ms)
    √ The owner can set maximum buy but a vandal can't (244ms)
    √ The owner can set maximum burn but a vandal can't (241ms)
    √ Investor can approve allowance and spender can transfer tokens from investor (1060ms)
    Investor purchases Tokens
      √ Investors can't transfer Tokens if Tradable is off (111ms)
      √ Investors can transfer Tokens if Tradable is on (390ms)


  15 passing (14s)
```
