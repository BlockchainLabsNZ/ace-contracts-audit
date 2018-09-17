pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------------------------
// Ace Token by Ace Limited.
// An ERC20 standard
//
// author: Ace Team
// Contact: xuhan.wang@asiainnovations.com

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 _totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    // transfer _value amount of token approved by address _from
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // approve an address with _value amount of tokens
    function approve(address _spender, uint256 _value) public returns (bool success);

    // get remaining token approved by _owner to _spender
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}
contract Ace is ERC20Interface {
    using SafeMath for uint;
    uint256 public constant decimals = 8;

    uint256 public constant oneAce = 10**8;
    uint256 public constant oneEth = 10**18;

    string public constant symbol = "ACE";
    string public constant name = "Ace";

    //initial selling
    bool public _selling = true;
    
    // total supply is 10^18 unit, equivalent to 10^10 Ace, 10bln
    uint256 public _totalSupply = oneAce.mul(10 ** 10); //(10 ** 10) * oneAce;
    
    // _originalBuyPrice = how many ACE unit for 1 ETH 
    // 1 ACE = 0.012 USD with the fixed rate
    // e.g. suppose 1 ETH = 275.52 USD, so _originalBuyPrice = 275.52 / 0.012 * oneAce = 22960 * oneAce = 22960 * 10**8 ACE unit
    uint256 public _originalBuyPrice = oneAce.mul(22960); //22960 * oneAce;

    // Owner of this contract
    address public owner;
 
    // Balances Ace for each account
    mapping(address => uint256) private balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) private allowed;

    // List of approved investors
    mapping(address => bool) private approvedInvestorList;
    
    // deposit
    mapping(address => uint256) private deposit;
    
    // icoPercent
    uint256 public _icoPercent = 10;
    
    // _icoSupply is the avalable unit. Initially, it is _totalSupply
    uint256 public _icoSupply = _totalSupply.mul(_icoPercent).div(100);
    
    // minimum buy 0.3 ETH, in wei
    uint256 public _minimumBuy = 3 * 10 ** 17;
    
    // maximum buy 25 ETH, in wei
    uint256 public _maximumBuy = 25 * oneEth;

    // totalTokenSold
    uint256 public totalTokenSold = 0;
    
    // tradable
    bool public tradable = false;
    
    // maximum token allowed to burn every time
    uint256 public _maximumBurn = 0;
    
    // Triggered whenever burn(uint256 _value) is called. 
    event Burn(address indexed burner, uint256 value);
    // Triggered whenever turnOnSale()、turnOffSale() is called.
    event Sale(address indexed safer, bool value);
    // Triggered whenever turnOnTradable() is called.
    event Tradable(address indexed safer, bool value);
    //
    event ParamConfig(uint256 paramType, uint256 value);

    /**
     * Functions with this modifier can only be executed by the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Functions with this modifier check on sale status
     * Only allow sale if _selling is on
     */
    modifier onSale() {
        require(_selling);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of address is investor
     */
    modifier validInvestor() {
        require(approvedInvestorList[msg.sender]);
        _;
    }
    
    /**
     * Functions with this modifier check the validity of msg value
     * value must greater than equal minimumBuyPrice
     * total deposit must less than equal maximumBuyPrice
     */
    modifier validValue(){
        // require value >= _minimumBuy AND total deposit of msg.sender <= maximumBuyPrice
        require ( (msg.value >= _minimumBuy) &&
                ( (deposit[msg.sender] + msg.value) <= _maximumBuy) );
        _;
    }
    
    /**
     * Functions with this modifier check the validity of address is not 0
     */
    modifier validAddress {
        require(address(0) != msg.sender);
        _;
    }
    
    /**
     * 
     */
    modifier isTradable(){
        require(tradable == true || msg.sender == owner);
        _;
    }

    /// @dev Fallback function allows to buy ether.
    function()
        public
        payable {
        buyAce();
    }
    
    /// @dev buy function allows to buy ether. for using optional data
    function buyAce()
        public
        payable
        onSale
        validValue
        validInvestor {
        // (ETH from msg.sender in wei) * (how many ACE unit for 1 ETH) / (how many wei for 1 ETH) 
        //uint256 requestedUnits = (msg.value * _originalBuyPrice) / 10**18;
        uint256 requestedUnits = msg.value.mul(_originalBuyPrice).div(oneEth);
        require(balances[owner] >= requestedUnits);
        // prepare transfer data
        balances[owner] = balances[owner].sub(requestedUnits);
        balances[msg.sender] = balances[owner].add(requestedUnits);
        // increase total deposit amount
        deposit[msg.sender] = deposit[msg.sender].add(msg.value);
        totalTokenSold = totalTokenSold.add(requestedUnits);
        // check total and auto turnOffSale
        if (totalTokenSold >= _icoSupply){
            _selling = false;
        }
        
        // submit transfer
        Transfer(owner, msg.sender, requestedUnits);
        owner.transfer(msg.value);
    }

    /// @dev Constructor
    function Ace() 
        public {
        owner = msg.sender;
        setBuyPrice(_originalBuyPrice);
        balances[owner] = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }
    
    /// @dev Gets totalSupply
    /// @return Total supply
    function totalSupply()
        public 
        constant 
        returns (uint256) {
        return _totalSupply;
    }
    
    /// @dev Enables sale 
    function turnOnSale() onlyOwner 
        public {
        _selling = true;
        Sale(msg.sender, true);
    }

    /// @dev Disables sale
    function turnOffSale() onlyOwner 
        public {
        _selling = false;
        Sale(msg.sender, false);
    }
    
    function turnOnTradable() 
        public
        onlyOwner{
        tradable = true;
        Tradable(msg.sender, true);
    }
    
    /// @dev set new icoPercent
    /// @param newIcoPercent new value of icoPercent
    function setIcoPercent(uint256 newIcoPercent)
        public 
        onlyOwner {
        _icoPercent = newIcoPercent;
        //_icoSupply = _totalSupply * _icoPercent / 100;
        _icoSupply = _totalSupply.mul(_icoPercent).div(100);
        ParamConfig(1, _icoPercent);
    }
    
    /// @dev set new _minimumBuy
    /// @param newMinimumBuy new value of _minimumBuy
    function setMinimumBuy(uint256 newMinimumBuy)
        public 
        onlyOwner {
        _minimumBuy = newMinimumBuy;
        ParamConfig(2, _minimumBuy);
    }
    
    /// @dev set new _maximumBuy
    /// @param newMaximumBuy new value of _maximumBuy
    function setMaximumBuy(uint256 newMaximumBuy)
        public 
        onlyOwner {
        _maximumBuy = newMaximumBuy;
        ParamConfig(3, _maximumBuy);
    }

    /// @dev Updates buy price (owner ONLY)
    /// @param newBuyPrice New buy price (in unit)
    function setBuyPrice(uint256 newBuyPrice) 
        onlyOwner 
        public {
        require(newBuyPrice>0);
        
        // buy price = how many ACE unit for 1 ETH
        // 1 ACE = 0.012 USD with the fixed rate
        // e.g. suppose 1 ETH = 275.52 USD, so _originalBuyPrice = 275.52 / 0.012 * oneAce = 22960 * oneAce = 22960 * 10**8 ACE unit
        _originalBuyPrice = newBuyPrice;
        
        // control _maximumBuy_USD = 3,000 USD, Ace price is 0.012 USD
        // maximumBuy_Ace = 3000 / 0.012 = 250,000 Ace = 250,000,00000000 unit
        // maximumETH = maximumBuy_Ace / _originalBuyPrice = 250,000,00000000 / 22,960,00000000
        // 250,000,00000000 / 22,960,00000000 ~ 10ETH => change to wei
        // so _maximumBuy = (how many wei for 1 ETH) * maximumBuy_Ace / _originalBuyPrice
        //_maximumBuy = (10**18) * 250000 * oneAce /_originalBuyPrice;
        _maximumBuy = oneAce.mul(250000).mul(oneEth).div(_originalBuyPrice) ;
        ParamConfig(4, _originalBuyPrice);
    }
        
    /// @dev Gets account's balance
    /// @param _addr Address of the account
    /// @return Account balance
    function balanceOf(address _addr) 
        public
        constant 
        returns (uint256) {
        return balances[_addr];
    }
    
    /// @dev check address is approved investor
    /// @param _addr address
    function isApprovedInvestor(address _addr)
        public
        constant
        returns (bool) {
        return approvedInvestorList[_addr];
    }
    
    /// @dev get ETH deposit
    /// @param _addr address get deposit
    /// @return amount deposit of an buyer
    function getDeposit(address _addr)
        public
        constant
        returns(uint256){
        return deposit[_addr];
    }
    
    /// @dev Adds list of new investors to the investors list and approve all
    /// @param newInvestorList Array of new investors addresses to be added
    function addInvestorList(address[] newInvestorList)
        onlyOwner
        public {
        // maximum 150 investors per transaction, to avoid out of gas issue
        require(newInvestorList.length <= 150);
        for (uint256 i = 0; i < newInvestorList.length; i++){
            approvedInvestorList[newInvestorList[i]] = true;
        }
    }

    /// @dev Removes list of investors from list
    /// @param investorList Array of addresses of investors to be removed
    function removeInvestorList(address[] investorList)
        onlyOwner
        public {
        // maximum 150 investors per transaction, to avoid out of gas issue
        require(investorList.length <= 150);
        for (uint256 i = 0; i < investorList.length; i++){
            approvedInvestorList[investorList[i]] = false;
        }
    }
 
    /// @dev Transfers the balance from msg.sender to an account
    /// @param _to Recipient address
    /// @param _amount Transfered amount in unit
    /// @return Transfer status
    function transfer(address _to, uint256 _amount)
        public 
        isTradable
        validAddress
        returns (bool) {
        // if sender's balance has enough unit and amount >= 0, 
        //      and the sum is not overflow,
        // then do transfer 
        require(balances[msg.sender] >= _amount);
        require(_amount >= 0);
        require(balances[_to] + _amount > balances[_to]);
        require(_to != address(0));

        /*balances[msg.sender] -= _amount;
        balances[_to] += _amount;*/
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        Transfer(msg.sender, _to, _amount);
        return true;
    }
     
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
    public
    isTradable
    validAddress
    returns (bool success) {
        require(balances[_from] >= _amount);
        require(allowed[_from][msg.sender] >= _amount);
        require(_amount > 0);
        require(balances[_to] + _amount > balances[_to]);
        require(_to != address(0));

        /*balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;*/

        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        Transfer(_from, _to, _amount);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) 
        public
        isTradable
        validAddress
        returns (bool success) {
        // not allowed to overwrite unless the _amount is 0 to prevent the race condition attack
        // caller must first reduce the spender's allowance to 0 and set the desired value afterwards
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    // get allowance
    function allowance(address _owner, address _spender) 
        public
        constant 
        returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    /// @dev Withdraws Ether in contract (Owner only)
    /// @return Status of withdrawal
    function withdraw() onlyOwner 
        public 
        returns (bool) {
        return owner.send(this.balance);
    }
    
    /// @dev set new _maximumBurn
    /// @param newMaximumBurn new value of _maximumBurn
    function setMaximumBurn(uint256 newMaximumBurn)
        public 
        onlyOwner {
        _maximumBurn = newMaximumBurn;
    }
    
    /// @dev Burns a specific amount of tokens.
    /// @param _value The amount of token to be burned.
    function burn(uint256 _value)
        public
        onlyOwner {
        require(_value > 0 && _value <= _maximumBurn);
        require(balances[msg.sender] >= _value);
        require(_totalSupply >= _value);
        //balances[msg.sender] -= _value;
        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        //balances[0x0] += _value;
        //Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);
    }
}

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
    event CoinCreation(address coin);

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
    bool flag = true;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this))
            revert();
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            revert();
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            revert();
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0)
            revert();
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            revert();
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0)
            revert();
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            revert();
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function MultiSigWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
                revert();
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param owner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        OwnerRemoval(owner);
        OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
    
    /// @dev Create new coin.
    function createCoin()
        external
        onlyWallet
    {
        require(flag == true);
        CoinCreation(new Ace());
        flag = false;
    }
}
