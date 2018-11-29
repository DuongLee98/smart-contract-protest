pragma solidity ^0.4.11;

contract Manage
{
    struct mninfo
    {
        bool status;
        uint256 date;
    }
    mapping(string => uint256[]) mnlistgroup;
    mapping(string => mapping(uint256 =>mninfo)) mndata;
    mapping(string => mapping(uint256 => uint256)) mnindex;
    mapping(uint256 => string) mnteacher;
    mapping(uint256 => bool) mngroupexist;
    
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
    
    function addManage(string u, uint256 g) onlyOtherContract public
    {
        require(!getStatus(u, g));
        mndata[u][g].date = now;
        mnindex[u][g] = mnlistgroup[u].push(g)-1;
        mnteacher[g] = u;
        mndata[u][g].status = true;
        mngroupexist[g] = true;
    }
    
    function deleteManage(string u, uint256 g) onlyOtherContract public
    {
        require(mndata[u][g].status == true);
        mnteacher[g] = "";
        for (uint256 i = mnindex[u][g]+1; i<getLengthGroupTeacherManage(u); i++)
        {
            mnlistgroup[u][i-1] = mnlistgroup[u][i];
            mnindex[u][mnlistgroup[u][i]]--;
        }
        mnlistgroup[u].length--;
        mndata[u][g].status = false;
        mngroupexist[g] = false; 
    }
    
    function getAllIdGroupTeacher(string u) public view returns(uint256[])
    {
        return mnlistgroup[u];
    }
    
    function getLengthGroupTeacherManage(string u) view public returns(uint256)
    {
        return mnlistgroup[u].length;
    }
    
    function getDate(string u, uint256 g) view public returns(uint256)
    {
        require(getStatus(u, g));
        return mndata[u][g].date;
    }
    
    function getTeacher(uint256 g) view public returns(string)
    {
        require(groupExist(g));
        return mnteacher[g];
    }
    
    function getGroup(string u, uint256 i) view public returns(uint256)
    {
        require(i>=0 && i<getLengthGroupTeacherManage(u));
        mnlistgroup[u][i];
    }
    
    function getStatus(string u, uint256 g) view public returns(bool)
    {
        return mndata[u][g].status;
    }
    
    function groupExist(uint256 u) view public returns(bool) 
    {
        return mngroupexist[u];
    }
}
