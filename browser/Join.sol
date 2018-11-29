pragma solidity ^0.4.11;

contract Join
{
    uint8 none = 0;
    uint8 accept = 1;
    uint8 join = 2;
    uint8 add = 3;
    uint8 urefuse = 4;
    uint8 grefuse = 5;
    
    address owner;
    address othercontract;
    
    mapping (string => mapping (uint256 => uint8)) jstatus;
    mapping (string => uint256 []) jlistgroup;
    mapping (string => mapping (uint256 => uint256)) jindexgroup;
    mapping (uint256 => string []) jlistuser;
    mapping (uint256 => mapping(string => uint256)) jindexuser;
    
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
    
    function groupAddUser(string u, uint256 g) onlyOtherContract public
    {
        require(jstatus[u][g] != accept);
        require(jstatus[u][g] != add);
        if (jstatus[u][g] == join)
        {
            jstatus[u][g] = accept;
        }
        else if (jstatus[u][g] == none)
        {
            jstatus[u][g] = add;
            jindexuser[g][u] = jlistuser[g].push(u) - 1;
            jindexgroup[u][g] = jlistgroup[u].push(g) -1;
        }
        else if (jstatus[u][g] == urefuse)
        {
            jstatus[u][g] = add;
            jindexgroup[u][g] = jlistgroup[u].push(g) -1;
        }
        else if (jstatus[u][g] == grefuse)
        {
            jstatus[u][g] = add;
            jindexuser[g][u] = jlistuser[g].push(u) - 1;
        }
    }
    
    function userJoinGruop(string u, uint256 g) onlyOtherContract public
    {
        require(jstatus[u][g] != accept);
        require(jstatus[u][g] != join);
        if (jstatus[u][g] == add)
        {
            jstatus[u][g] = accept;
        }
        else if (jstatus[u][g] == none)
        {
            jstatus[u][g] = join;
            jindexuser[g][u] = jlistuser[g].push(u) - 1;
            jindexgroup[u][g] = jlistgroup[u].push(g) -1;
        }
        else if (jstatus[u][g] == grefuse)
        {
            jstatus[u][g] = join;
            jindexuser[g][u] = jlistuser[g].push(u) - 1;
        }
        else if (jstatus[u][g] == urefuse)
        {
            jstatus[u][g] = join;
            jindexgroup[u][g] = jlistgroup[u].push(g) -1;
        }
    }
    
    function userRefuseGroup(string u, uint256 g) onlyOtherContract public
    {
        require(jstatus[u][g] != none);
        require(jstatus[u][g] != urefuse);
        if (jstatus[u][g] == join || jstatus[u][g] == accept)
        {
            deleteUser(u, g);
            deleteGroup(u, g);
            jstatus[u][g] = none;
        }
        else if (jstatus[u][g] == add)
        {
            deleteGroup(u, g);
            jstatus[u][g] = urefuse;
        }
        else if (jstatus[u][g] == grefuse)
        {
            deleteUser(u, g);
            jstatus[u][g] = none;
        }
    }
    
    function groupRefuseUser(string u, uint256 g) onlyOtherContract public
    {
        require(jstatus[u][g] != none);
        require(jstatus[u][g] != grefuse);
        if (jstatus[u][g] == add || jstatus[u][g] == accept)
        {
            deleteUser(u, g);
            deleteGroup(u, g);
            jstatus[u][g] = none;
        }
        else if (jstatus[u][g] == join)
        {
            deleteUser(u, g);
            jstatus[u][g] = grefuse;
        }
        else if (jstatus[u][g] == urefuse)
        {
            deleteGroup(u, g);
            jstatus[u][g] = none;
        }
    }
    
    function deleteUser(string u, uint256 g) private
    {
        require(jstatus[u][g] != none);
        require(jstatus[u][g] != grefuse);
        for (uint256 i=jindexuser[g][u]+1; i<getLengthJUser(g); i++)
        {
            jlistuser[g][i-1] = jlistuser[g][i];
            jindexuser[g][jlistuser[g][i]]--;
        }
        jlistuser[g].length--;
    }
    
    function deleteAllUserInGroup(uint256 g) onlyOtherContract public
    {
        for(uint256 i=0; i<getLengthJUser(g); i++)
        {
            if (jstatus[getJUser(g, i)][g] != none && jstatus[getJUser(g, i)][g] != urefuse)
            {
                deleteGroup(getJUser(g, i), g);
                jstatus[getJUser(g, i)][g] = none;
            }
        }
        jlistuser[g].length = 0;
        
    }
    
    function deleteGroup(string u, uint256 g) private
    {
        require(jstatus[u][g] != none);
        require(jstatus[u][g] != urefuse);
        for (uint256 i=jindexgroup[u][g]+1; i<getLengthJGroup(u); i++)
        {
            jlistgroup[u][i-1] = jlistgroup[u][i];
            jindexgroup[u][jlistgroup[u][i]]--;
        }
        jlistgroup[u].length--;
    }
    
    function getAllGroupOfUser(string u) view public returns(uint256[])
    {
        return jlistgroup[u];
    }
    
    function getLengthJUser(uint256 g) view public returns(uint256)
    {
        return jlistuser[g].length;
    }
    
    function getLengthJGroup(string u) view public returns(uint256)
    {
        return jlistgroup[u].length;
    }
    
    function getJGroup(string u, uint256 i) view public returns(uint256)
    {
        require(i>=0 && i<getLengthJGroup(u));
        return jlistgroup[u][i];
    }
    
    function getJUser(uint256 g, uint256 i) view public returns(string)
    {
        require(i>=0 && i<getLengthJUser(g));
        return jlistuser[g][i];
    }
    
    function getJStatus(string u, uint256 g) view public returns(uint256)
    {
        return jstatus[u][g];
    }
}
