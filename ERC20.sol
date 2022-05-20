// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance (address tokenOwner, address spender) external view returns (uint remaining);
    function approve (address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    // Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

abstract contract Block is ERC20Interface {
    string public name = "Block"; // This will be the name of token
    string public symbol = "BLK"; // Just like bitcoin have BTC, ethereum has ETH we are going to give it BLK
    uint public decimal = 0;  // upto how much decimal places are token is divisible, In ERC it's upto 20 decimal number but for this i am taking 0 because i am not going to divide this ERC token.
     
    uint public override totalSupply; // here override is writtern because i am using the same function which is already available in interface. 
    address public founder; // founder of this token.

    mapping(address => uint) public balances;

    constructor () {
         totalSupply = 100000;
         founder = msg.sender;
         balances[founder]  = totalSupply;
    }
}
