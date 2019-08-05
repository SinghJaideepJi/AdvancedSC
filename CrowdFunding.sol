pragma solidity ^0.5.8;

contract CrowdFunding{
    
    address payable public owner;
    mapping (address => uint256) contribution;
    uint256 totalContribution;
    uint256 maxPaymentDevs;
    uint256 remainingTotalContribution;
    uint256 totalRefundAmount;
    bytes32 IdeaDescription;
    uint256 numContributors;
    uint256 public yesVote;
    uint256 public noVote;
    mapping (address => bool) voted;
    bool freezeFunds;
    bool depositAllowed;
    bool withdrawAllowed;
    bool votingOpen;
    
    event Deposit(address addr, uint256 amount, uint256 numContributors, uint256 totalContribution);
    event Withdrawal(address addr, uint256 amount, uint256 numContributors, uint256 totalContribution);
    event voteToReleasePayment();
    event developersWerePaid(uint256 maxPaymentDevs, uint256 remainingTotalContribution);
    
    // Share the IPFS location where the description is present
    constructor () public{
        //IdeaDescription = _description; bytes32 _description
        owner = msg.sender;
        
        totalContribution = 0;
        remainingTotalContribution = 0;
        totalRefundAmount = 0;
        yesVote=0;
        noVote=0;
        numContributors = 0;
        depositAllowed = true;
        withdrawAllowed = false;
        votingOpen = false;
    }
    
    modifier isDepositAllowed(){
        require(depositAllowed == true,"Deposits are freezed. Deposits are not allowed");
        _;
    }
    
    modifier isWithdrawAllowed(){
        require(withdrawAllowed == true,"Withdrawls are freezed.  Withdrawls are not allowed");
        _;
    }
    
    modifier isVotingOpen(){
        require(votingOpen == true,"Voting is Closed");
        _;
    }
    
    modifier isOwner(){
        require(msg.sender == owner, "Only Contract owner can call this function!");
        _;
    }
    
    modifier onlyVerified(bytes32 messageHash, bytes memory flatSignature) {
        require(contribution[verifySignature(messageHash,flatSignature)] == 0, 'Not a valid contributor.');
        _;
    }
    
    function splitSignature(bytes memory _sig) internal pure returns (uint8, bytes32, bytes32) {
        require(_sig.length == 65, "Verification: invalid sig");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(_sig, 32))
            // second 32 bytes
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(_sig, 96)))
        }

        return (v, r, s);
    }
    
    function verifySignature(bytes32 messageHash, bytes memory flatSignature) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        (v, r, s) = splitSignature(flatSignature);

        return ecrecover(hash, v, r, s);
    }

    function fund() public isDepositAllowed payable{
        require(msg.value >= 0.1 ether, "Minimum 0.1 ether contribution required");
        
        contribution[msg.sender] = msg.value;
        totalContribution = totalContribution + contribution[msg.sender];
        numContributors++;
        
        // Closed funding when limit of contributers reach
        if(numContributors == 3){
            depositAllowed = false;
            
            // Contract Owner can ask for only 10% of the money at a time
            maxPaymentDevs = totalContribution/10;
            remainingTotalContribution = totalContribution;
        }
        
        emit Deposit(msg.sender,contribution[msg.sender],numContributors,totalContribution);
    }
    
    function withdrawFunds() public isWithdrawAllowed{
        uint256 contributed = contribution[msg.sender];
        require(contributed > 0, "Your contribution is 0. You cannot withdraw.");
        
        uint amount  = contributed/totalContribution * totalRefundAmount;
        
        contribution[msg.sender] = 0;
        numContributors--;
        remainingTotalContribution = remainingTotalContribution - amount;
        
        emit Withdrawal(msg.sender,amount,numContributors,remainingTotalContribution);
        msg.sender.transfer(amount);
    }
    
    function happyWithProgress(bool _vote,bytes32 messageHash, bytes memory flatSignature) isVotingOpen onlyVerified(messageHash,flatSignature) public{
        require(contribution[msg.sender] > 0, "Your contribution is 0. You cannot Vote.");
        require(voted[msg.sender] == false,"Already voted for this round");
        
        voted[msg.sender] = true;
        if(_vote){
            yesVote++;
        }else{
            noVote++;
        }
        
        // If contributors are unhappy with Project progress then unlock Funds and allow Withdrawal.
        if (noVote >= 2*(numContributors/3) ){
            withdrawAllowed = true;
            totalRefundAmount = remainingTotalContribution;
            cleanupVotes();
        }
        
        // If contributors are happy with Project progress then release the payment to the developers
        if (yesVote >= 2*(numContributors/3) ){
            payTheDevs();
            cleanupVotes();
        }
    }
    
    function cleanupVotes() private{
        votingOpen = false;
        yesVote = 0;
        noVote = 0;
    }
    
    // Only Contract owner can ask to pay the developers
    function askForMoney() isOwner public{
        votingOpen = true;
        emit voteToReleasePayment();
    }
    
    // Private as it does not need to be exposed to the public
    function payTheDevs() private{
        remainingTotalContribution = remainingTotalContribution - maxPaymentDevs;
        emit developersWerePaid(maxPaymentDevs,remainingTotalContribution);
        owner.transfer(maxPaymentDevs);
    }
}