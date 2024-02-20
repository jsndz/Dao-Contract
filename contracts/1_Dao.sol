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
     mapping (uint=>Proposal) public proposals;
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
        contributionTimeEnd = block.timestamp +_contributionTimeEnd;
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
    function contribution() public payable  {
        require(contributionTimeEnd>=block.timestamp,"Contribution time ended");
        require(msg.value>0,"Send more than 0 ether");
        isInvestor[msg.sender]= true;
        numOfshares[msg.sender] = numOfshares[msg.sender] + msg.value;
        totalshares= totalshares +msg.value;
        availableFunds+= msg.value;
        InvestorList.push(msg.sender);
    }
    function redeemShares(uint amount) public onlyInvestor(){
        require(numOfshares[msg.sender]<=amount,"Not enough shares");
        require(availableFunds<=amount,"Not enough funds");
        numOfshares[msg.sender]-=amount;
        if(numOfshares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        availableFunds-=amount;
        payable (msg.sender).transfer(amount);
    }
    function transferShare(uint amount, address to) public  onlyInvestor() {
        require(numOfshares[msg.sender]<=amount,"Not enough shares");
        require(availableFunds<=amount,"Not enough funds");
        numOfshares[msg.sender]-=amount;
        if(numOfshares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }
        numOfshares[to]+=amount;
        isInvestor[to]=true;
        InvestorList.push(to);
    }
    function createProposal(string calldata description,uint amount,address payable recipient) public onlyManager(){
        require(availableFunds<=amount,"Not enough funds");
        proposals[nextProposalId]=Proposal(nextProposalId,description,amount,recipient,0,block.timestamp+voteTime,false);
        nextProposalId++;
    }

    function voteProposal(uint proposalId) public onlyInvestor(){
        Proposal storage proposal =proposals[proposalId];
        require(isVoted[msg.sender][proposalId]==false,"You have already voted");
        require(proposal.end>=block.timestamp,"Voting Time Ended");
        require(proposal.executed==false,"It is already executed");
        isVoted[msg.sender][proposalId]=true;
        proposal.votes+=numOfshares[msg.sender];
    }
}