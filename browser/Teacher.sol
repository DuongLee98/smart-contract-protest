pragma solidity ^0.4.11;

contract Teacher
{
    string [] tuser;
    struct tinfo
    {
        string pass;
        string name;
        string phone;
        string ic;
        bool value;
    }
    mapping (string => tinfo) tdata;
    mapping (string => uint256) tid;
    
    function addTUser(string u, string pw, string n, string p, string ic) internal
    {
        tdata[u].pass = pw;
        tdata[u].name = n;
        tdata[u].phone = p;
        tdata[u].ic = ic;
        tdata[u].value = true;
        tid[u] = tuser.push(u) - 1;
    }
    
    function deleteTUser(string u, string pw) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), pw)==true);
        tdata[u].pass = "";
        tdata[u].name = "";
        tdata[u].phone = "";
        tdata[u].ic = "";
        tdata[u].value = false;
        for (uint256 i=tid[u]+1; i<getLengthTUser(); i++)
        {
            tuser[i-1] = tuser[i];
            tid[tuser[i]]--;
        }
        tuser.length--;
        tid[u] = 0;
    }
    
    function editTUser(string u, string paw, string pw, string n, string p, string ic) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), paw)==true);
        tdata[u].pass = pw;
        tdata[u].name = n;
        tdata[u].phone = p;
        tdata[u].ic = ic;
    }
    
    function setPassTUser(string u, string paw, string pw) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), paw)==true);
        tdata[u].pass = pw;
    }
    
    function setNameTUser(string u, string pw, string n) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), pw)==true);
        tdata[u].name = n;
    }
    
    function setPhoneTUser(string u, string pw, string p) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), pw)==true);
        tdata[u].phone = p;
    }
    
    function setIcTUser(string u, string pw, string ic) public payable
    {
        require(userTExist(u));
        require(compareStringT(getPassTUser(u), pw)==true);
        tdata[u].ic = ic;
    }
    
    function getPassTUser(string u) internal view returns (string)
    {
        require(userTExist(u));
        return tdata[u].pass;
    }
    
    function getNameTUser(string u) public view returns (string)
    {
        require(userTExist(u));
        return tdata[u].name;
    }
    
    function getPhoneTUser(string u) public view returns (string)
    {
        require(userTExist(u));
        return tdata[u].phone;
    }
    
    function getIcTUser(string u) public view returns (string)
    {
        require(userTExist(u));
        return tdata[u].ic;
    }
    
    function getLengthTUser() public view returns(uint256)
    {
        return tuser.length;
    }
    
    function getTUser(uint256 i) public view returns(string)
    {
        require (getLengthTUser()!=0 && i<=getLengthTUser()-1 || i>=0);
        return (tuser[i]);
    }
    
    function userTExist(string u) public view returns(bool)
    {
        return tdata[u].value;
    }
    
    function compareStringT(string a, string b) internal pure returns(bool)
    {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}
