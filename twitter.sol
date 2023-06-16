//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Twitter{
    struct Tweet{
        uint id;
         address author;
        string content;
        uint createdAt;
    }

    struct Message{
        uint id;
        string content;
        address from;
        address to;
        uint createdAt;
    }

    mapping (uint => Tweet) public tweets;
    mapping (address => uint[]) public tweetsOf; 
    mapping (address => Message[]) public coversations;
    mapping (address => mapping(address => bool)) public operators;
    mapping (address => address[]) public following;
    address public caller;
    address public accessor;
    modifier onlyOwner() {
        require(msg.sender == caller, "Only the contract owner can call this function.");
        _; 
    }
    modifier onlyOperator(){
        require(msg.sender == accessor, "you must need to be an operator");
        _;
    }
    uint nextId;
    uint nextMessageId;

    function _tweet(string memory _content, address _from) internal  {
        tweets[nextId] = Tweet(nextId, _from ,_content, block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId = nextId + 1;
    }

    function _sendMessage(address _from, address _to, string memory _content) internal {
        coversations[_from].push(Message(nextMessageId, _content, _from, _to, block.timestamp));
        nextMessageId = nextMessageId + 1;
    }
    function tweet(string memory _content) public onlyOwner{
        _tweet(_content, msg.sender);
    }
    function tweet(string memory _content, address _from) public onlyOperator{
        _tweet(_content, _from);
    }

    function sendMessage(address _to, string memory _content) public onlyOwner{
        _sendMessage(msg.sender, _to, _content);
            }

    function sendMessage(address _from, address _to, string memory _content) public onlyOperator{
        _sendMessage(_from, _to, _content);
    }

    function follow(address _followed) public onlyOwner onlyOperator{
        following[msg.sender].push(_followed);
    }

    function allowAccess(address _operator) public onlyOwner{
        operators[msg.sender][_operator] = true;
    }

     function disAllowAccess(address _operator) public onlyOwner{
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweets(uint count) public view returns(Tweet[] memory){
        require(count > 0 && count <= nextId, "invalid count");
        Tweet[] memory _tweets = new Tweet[](count);
        uint j;
        for(uint i = nextId - count; i < nextId; i++){
            Tweet storage _structure = tweets[i];
            _tweets[j] = Tweet(_structure.id, _structure.author, _structure.content, _structure.createdAt);
            j = j+1;
        }
        return _tweets;
    }

    function tweetsOfUser(uint count, address _user) public view returns (Tweet[] memory){
        Tweet[] memory _tweets = new Tweet[](count);
        uint[] memory ids = tweetsOf[_user];
        require (count > 0 && count <= nextId, "invalid count");
        uint j;
        for(uint i = ids.length - count; i < ids.length; i++){
            Tweet storage _structure = tweets[ids[i]];
            _tweets[j] = Tweet(_structure.id, _structure.author, _structure.content, _structure.createdAt);
            j = j+1;
        }
        return _tweets;
    }
}