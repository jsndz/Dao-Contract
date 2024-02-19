// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Dao{
    struct Proposal{
        uint id;
        string description;
        uint amount;
        address payable recipient;
        uint votes;
        uint end;
        bool executed;
    }

    mapping(address=>bool) private isInvestor;
    mapping(address=>uint) public numOfshares;
    mapping(address=>mapping (uint=>bool)) public isVoted;
     mapping(address=>mapping (address =>bool)) public withdrawlStatus;
     mapping (address=>uint) public proposals;
     address[] public InvestorList;
    uint public  totalshares;
     uint public  availableFunds;
    uint public  contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public manager;

    constructor(uint _contributionTimeEnd, uint _voteTime, uint _quorum){
        require(_quorum>0 && _quorum<100,"Not a valid value");
        contributionTimeEnd = _contributionTimeEnd;
        quorum = _quorum;
        voteTime = _voteTime;
        manager = msg.sender;

    }


        modifier onlyInvestor(){
            require(isInvestor[msg.sender]==true,"Not an investor");
            _;
        }


        modifier onlyManager(){
            require(manager==msg.sender,"Not an manager");
            _;
        }
}