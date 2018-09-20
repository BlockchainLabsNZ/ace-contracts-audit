# Ace Smart Contract Audit Report
<br>

## Preamble
This audit report was undertaken by <b>BlockchainLabs.nz</b> for the purpose of providing feedback to <b>Ace</b>. <br>It has subsequently been shared publicly without any express or implied warranty.

Solidity contracts were sourced directly from the Ace team, we would encourage all community members and token holders to make their own assessment of the contracts once they are deployed and verified.

<br>

## Scope
The following contract was a subject for static, dynamic and functional analyses:

Contracts
  - [Ace.sol](https://github.com/BlockchainLabsNZ/ace-contracts-audit/blob/audit/contracts/ace.sol)
<br>

## Focus areas
The audit report is focused on the following key areas - though this is not an exhaustive list.


### Correctness
- No correctness defects uncovered during static analysis?
- No implemented contract violations uncovered during execution?
- No other generic incorrect behaviour detected during execution?
- Adherence to adopted standards such as ERC20?

### Testability
- Test coverage across all functions and events?
- Test cases for both expected behaviour and failure modes?
- Settings for easy testing of a range of parameters?
- No reliance on nested callback functions or console logs?
- Avoidance of test scenarios calling other test scenarios?

### Security
- No presence of known security weaknesses?
- No funds at risk of malicious attempts to withdraw/transfer?
- No funds at risk of control fraud?
- Prevention of Integer Overflow or Underflow?

### Best Practice
- Explicit labeling for the visibility of functions and state variables?
- Proper management of gas limits and nested execution?
- Latest version of the Solidity compiler?

<br>

## Analysis

- [Functional tests](functional-test-report.md)
- [Dynamic analysis](dynamic-analysis.md)
- [Test coverage](test-coverage.md)

<br>

## Issues

### Severity Description
<table>
<tr>
  <td>Minor</td>
  <td>A defect that does not have a material impact on the contract execution and is likely to be subjective.</td>
</tr>
<tr>
  <td>Moderate</td>
  <td>A defect that could impact the desired outcome of the contract execution in a specific scenario.</td>
</tr>
<tr>
  <td>Major</td>
  <td> A defect that impacts the desired outcome of the contract execution or introduces a weakness that may be exploited.</td>
</tr>
<tr>
  <td>Critical</td>
  <td>A defect that presents a significant security vulnerability or failure of the contract across a range of scenarios.</td>
</tr>
</table>

### Minor
- **Recommend using SafeMath** - `Best practice` We recommend using the SafeMath library for calculations to be safe from under and overflows  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/5)
  - [ ] Partially fixed
- **Add a sanity check to TransferFrom for valid addresses** - `Observation` [#L94-L111](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol#L94-L111]) The `from` and `to` addresses are not checked to see if they are valid addresses, we would recommend checking to make sure they are not `address(0)`  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/4)
  - [x] Fixed: [5031f39c6](https://github.com/BlockchainLabsNZ/ace-contracts-audit/commit/5031f39c627ae915afb477a270132ae3aa7d5db4)
- **Prefer explicit variable types** - `Best practice` We recommend using explicit variable types instead of relying on the default type. For example, prefer using `uint256` instead of `uint`. This makes your intention clear, and it also guards you against a future where the default changes.  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/2)
  - [x] Fixed: [5031f39c6](https://github.com/BlockchainLabsNZ/ace-contracts-audit/commit/5031f39c627ae915afb477a270132ae3aa7d5db4)
- **Upgrade Solidity version** - `Best practice` We recommend using the latest stable version of Solidity. The newer versions of Solidity introduce some new useful features like adding error messages for failing `require` calls, and updating the constructor and event syntax.  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/1)
  - [ ] Not fixed

### Moderate
- **It is possible to sell more than the ICO Supply** - `Correctness`, Observation` When purchasing tokens, you can purchase more tokens than the `_icoSupply` variable. The purchase which exceeds the supply will trigger the end of the sale, but in the worst case and extra 24.999-ish ETH worth of tokens could be sold over the total intended supply.  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/3)
  - [ ] No fix required

### Major
- **Burning tokens does not update the totalSupply variable** - `Bug` Burning tokens (using the `burn` method, or using the current `transfer` and `transferFrom`) doesn't update the totalSupply  [View on GitHub](https://github.com/BlockchainLabsNZ/ace-contracts-audit/issues/7)
  - [x] Fixed: [5031f39c6](https://github.com/BlockchainLabsNZ/ace-contracts-audit/commit/5031f39c627ae915afb477a270132ae3aa7d5db4)

### Critical
- None found


<br>

## Observations
- It's a common practice to add events for setter functions. For example the `turnOnSale` function could emit a `SaleStarted` event
  - [x] Fixed: [5031f39c6](https://github.com/BlockchainLabsNZ/ace-contracts-audit/commit/5031f39c627ae915afb477a270132ae3aa7d5db4)
- The `maximumBuy` variable is set to 25 ETH initially, but as soon as the contract is deployed it will be changed. `setBuyPrice` is called in the contract constructor.
- The `setIcoPercent` function allows the owner to change the ICO Supply at any time, including while the crowdsale is active.

<br>

## Conclusion

The developers demonstrated an understanding of Solidity and smart contract development. We took part in carefully reviewing all source code provided, including static, dynamic, and functional testing methodology. The developers responded well to our feedback and made most of the changes we suggested to the contracts.

The owner of the contract does have a lot of control over the crowdsale as we noted in the observations section, but they are expecting to mitigate this through the use of a multisig contract to deploy the contract.

Overall we consider the resulting contracts following the audit feedback period adequate and have not identified any potential vulnerabilities. This contract has a low level risk of ETH and ACE being hacked or stolen from the inspected contracts.


<br>
___

### Disclaimer

Our team uses our current understanding of the best practises for Solidity and Smart Contracts. Development in Solidity and for Blockchain is an emerging area of software engineering which still has a lot of room to grow, hence our current understanding of best practise may not find all of the issues in this code and design.

We have not analysed any of the assembly code generated by the Solidity compiler. We have not verified the deployment process and configurations of the contracts. We have only analysed the code outlined in the scope. We have not verified any of the claims made by any of the organisations behind this code.

Security audits do not warrant bug-free code. We encourge all users interacting with smart contract code to continue to analyse and inform themselves of any risks before interacting with any smart contracts.
