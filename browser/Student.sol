pragma solidity ^0.4.11;

contract Student
{
    string [] suser;
    struct sinfo
    {
        string pass;
        string name;
        string phone;
        bool value;
    }
    mapping (string => sinfo) sdata;
    mapping (string => uint256) sid;
    
    function addSUser(string u, string pw, string n, string p) internal
    {
        sdata[u].pass = pw;
        sdata[u].name = n;
        sdata[u].phone = p;
        sdata[u].value = true;
        sid[u] = suser.push(u) - 1;
    }
    
    function deleteSUser(string u, string pw) public payable
    {
        require(userSExist(u));
        require(compareStringS(getPassSUser(u), pw)==true);
        sdata[u].pass = "";
        sdata[u].name = "";
        sdata[u].phone = "";
        sdata[u].value = false;
        for (uint256 i=sid[u]+1; i<getLengthSUser(); i++)
        {
            suser[i-1] = suser[i];
            sid[suser[i]]--;
        }
        suser.length--;
        sid[u] = 0;
    }
    
    function editSUser(string u, string paw, string pw, string n, string p) public payable
    {
        require(userSExist(u));
        require(compareStringS(getPassSUser(u), paw)==true);
        sdata[u].pass = pw;
        sdata[u].name = n;
        sdata[u].phone = p;
    }
    
    function setPassSUser(string u, string paw, string pw) public payable
    {
        require(userSExist(u));
        require(compareStringS(getPassSUser(u), paw)==true);
        sdata[u].pass = pw;
    }
    
    function setNameSUser(string u, string pw, string n) public payable
    {
        require(userSExist(u));
        require(compareStringS(getPassSUser(u), pw)==true);
        sdata[u].name = n;
    }
    
    function setPhoneSUser(string u, string pw, string p) public payable
    {
        require(userSExist(u));
        require(compareStringS(getPassSUser(u), pw)==true);
        sdata[u].phone = p;
    }
    
    function getPassSUser(string u) internal view returns (string)
    {
        require(userSExist(u));
        return sdata[u].pass;
    }
    
    function getNameSUser(string u) public view returns (string)
    {
        require(userSExist(u));
        return sdata[u].name;
    }
    
    function getPhoneSUser(string u) public view returns (string)
    {
        require(userSExist(u));
        return sdata[u].phone;
    }
    
    function getLengthSUser() public view returns(uint256)
    {
        return suser.length;
    }
    
    function getSUser(uint256 i) public view returns(string)
    {
        require (getLengthSUser()!=0 && i<=getLengthSUser()-1 || i>=0);
        return (suser[i]);
    }
    
    function userSExist(string u) public view returns(bool)
    {
        return sdata[u].value;
    }
    
    function compareStringS(string a, string b) internal pure returns(bool)
    {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}
