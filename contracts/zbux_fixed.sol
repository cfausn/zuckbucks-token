/**
 *Submitted for verification at Etherscan.io on 2019-06-23
*/

pragma solidity 0.5.8;

import './SafeMath.sol';

interface Token {

    /// @dev need to check whether interfaces can have events defined in them
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) view public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value)  public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}



contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public circulatingSupply;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev changed scope to internal to prevent double-spend exploit (not sure if it would prevent people from accepting it as ERC20)
    function approve(address _spender, uint256 _value) /*public*/ internal returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
        Should insert the following two functions, `increaseAllowance` and `decreaseAllowance`
        see OpenZeppelin or other libraries fix on this
        @dev
    */

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}


//name this contract whatever you'd like
contract ZuckBucks is StandardToken {
    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    address payable private owner;
    uint256 public totalSupply;

    uint256 public starting_giveaway;
    uint256 public next_giveaway;
    uint256 private giveaway_count;
    
    function () external payable {
        //if ether is sent to this address, send it back.
        uint256 eth_val = msg.value;
        
        uint256 giveaway_value;

        giveaway_count++;

        giveaway_value = (((starting_giveaway.div(giveaway_count)).add((starting_giveaway.div((giveaway_count.add(2))))).mul(10**18.add(eth_val))).div(10**18);
        next_giveaway = (starting_giveaway.div((giveaway_count.add(1)))).add(starting_giveaway.div(giveaway_count.add(3)));


        balances[msg.sender] = balances[msg.sender].add(giveaway_value);
        balances[owner] = balances[owner].sub(giveaway_value);
        circulatingSupply = circulatingSupply.add(giveaway_value);
        emit Transfer(owner, msg.sender, giveaway_value);
        
        // revert();
        owner.transfer(eth_val);
    }



    constructor() public {
        totalSupply = 1500000;                        // Update total supply (1500000 for example)
        balances[msg.sender] = totalSupply;               // Give the creator all initial tokens (100000 for example)
        circulatingSupply = 0;
        name = "Zuck Bucks";                                   // Set the name for display purposes
        decimals = 0;                            // Amount of decimals for display purposes
        symbol = "ZBUX";                               // Set the symbol for display purposes
        starting_giveaway = 50000;
        next_giveaway = 0;
        owner = msg.sender;
        giveaway_count = 0;
    }



}