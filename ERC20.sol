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

//   contract
contract Ropilo is ERC20Interface {
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

// ICO ( Initial Coin Offering )

contract ICO is Ropilo {
    address public manager;
    address payable public deposit; // This is the address where our investers deposit their ethers.

    uint256 tokenPrice = 0.1 ether; // Cost of 1 token.
    uint256 public cap = 300 ether; // how much of token we want in circulation.
    uint256 public raisedAmount; // this will check how much ethers are recieved.

    uint256 public icoStart = block.timestamp; // whenever we will deploy this contract the ico will start;
    uint256 public icoEnd = block.timestamp + 3600; // the ICO will end after 1 hour of deploying.

    uint256 public tokenTradeTime = icoEnd + 3600;

    uint256 public maxInvest = 10 ether; // maximum amount to invest
    uint256 public minInvest = 0.1 ether; // minimum amount to invest

    enum State {
        beforeStart,
        afterEnd,
        running,
        halted
    }

    State public icoState;

    event Invest(address investor, uint256 value, uint256 tokens);

    constructor(address payable _deposit) {
        deposit = _deposit;
        manager = msg.sender;
        icoState = State.beforeStart;
    }

    // Modifier for only manager can call specific function;
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function halt() public onlyManager {
        icoState = State.halted;
    }

    function resume() public onlyManager {
        icoState = State.running;
    }

    // for safety meausures in case of emergency.
    function changeDepositAddress(address payable newDeposit)
        public
        onlyManager
    {
        deposit = newDeposit;
    }

    //    get the state of enum State;
    function getState() public view returns (State) {
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < icoStart) {
            return State.beforeStart;
        } else if (block.timestamp >= icoStart && block.timestamp <= icoEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }


    // invest
    function invest() payable public returns(bool){
        icoState = getState();
        require(icoState == State.running);
        require(msg.value >= minInvest && msg.value <= maxInvest );
        require(raisedAmount <= cap);

        raisedAmount += msg.value;
        uint tokens = msg.value/tokenPrice;
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }


    
}
