pragma solidity ^0.4.11;

contract Group
{
    uint256 id = 1000;
    
    uint256 [] ids;
    
    
    
    mapping (uint256 => string) name;
    mapping (string => uint256) gid;
    mapping (string => bool) existname;
    mapping (uint256 => bool) existid;
    mapping (uint256 => uint256) index;
    
    address owner;
    address othercontract;
    
    constructor () public
    {
        owner = msg.sender;
    }
    
    modifier onlyOwner()
    {
        require (msg.sender == owner);
        _;
    }
    
    modifier onlyOtherContract()
    {
        require(msg.sender == othercontract);
        _;
    }
    
    function setOtherContract(address _adr) onlyOwner payable public
    {
        othercontract = _adr;
    }
    
    function addGroup(string n) onlyOtherContract public
    {
        require(!existNameGroup(n));
        name[id] = n;
        index[id] = ids.push(id)-1;
        gid[n] = id;
        existid[id] = true;
        existname[n] = true;
        id++;
    }
    
    function editGroup(uint256 i, string n) onlyOtherContract public
    {
        require(existIdGroup(i));
        existname[name[i]] = false;
        gid[name[i]] = 0;
        
        name[i] = n;
        gid[n] = i;
        existname[n] = true;
    }
    
    function deleteGroup(uint256 i) onlyOtherContract public
    {
        require(existIdGroup(i));
        existname[name[i]] = false;
        existid[i] = false;
        gid[name[i]] = 0;
        for (uint256 j=index[i]+1; j<getLengthIdGroup(); j++)
        {
            ids[j-1] = ids[j];
            index[ids[j]]--;
        }
        name[i] = "";
        ids.length--;
    }
    
    function getAllIdGroup() view public returns(uint256[])
    {
        return ids;
    }
    
    function getNameGroup(uint256 i) view public returns(string)
    {
        require(existIdGroup(i));
        return name[i];
    }
    
    function getIdNameGroup(string n) view public returns(uint256)
    {
        require(existNameGroup(n));
        return gid[n];
    }
    
    function getIdGroup(uint256 item) view public returns(uint256)
    {
        require(item>=0 && item<getLengthIdGroup());
        return ids[item];
    }
    
    function getLengthIdGroup() view public returns(uint256)
    {
        return ids.length;
    }
    
    function existNameGroup(string n) view public returns(bool)
    {
        return existname[n];
    }
    
    function existIdGroup(uint256 i) view public returns(bool)
    {
        return existid[i];
    }
    
}
