// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// interface of our erc20 project.
interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 tokens)
        external
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) external returns (bool success);

    // Events
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

contract Block is ERC20Interface {
    string public name = "Ropilo"; // This will be the name of token
    string public symbol = "ROP"; // Just like bitcoin have BTC, ethereum has ETH we are going to give it ROP
    uint256 public decimal = 0; // upto how much decimal places are token is divisible, In ERC it's upto 20 decimal number but for this i am taking 0 because i am not going to divide this ERC token.

    uint256 public override totalSupply; // the total tokens which are available.
    address public founder; // founder of this token.

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed; // nested mapping

    constructor() {
        // Here i am adding the total of 100000 tokens in totalSupply.
        totalSupply = 100000;

        // The owner who is deploying the contract.
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    // here override is writtern because i am using the same function which is available in interface.

    // Balance of token owner;
    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    // transfer the token
    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    //    Approve the transaction
    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    //  Owner will allow the transaction
    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    // tranfer tokens
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        balances[from] -= tokens;
        balances[to] += tokens;
        return true;
    }
}
