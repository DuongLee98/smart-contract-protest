pragma solidity ^0.4.11;

contract Make
{
    struct info
    {
        bool status;
        uint256 date;
        mapping(uint256 => bool) accept;
    }
    mapping(string => uint256[]) listexam;
    mapping(string => mapping(uint256 =>info)) data;
    mapping(string => mapping(uint256 => uint256)) index;
    mapping(uint256 => string) tuser;
    
    mapping(uint256 => bool) existexam;
    
    constructor () public
    {
        owner = msg.sender;
    }
    
    address owner;
    address othercontractset;
    address othercontractget;
    
    modifier onlyOwner()
    {
        require (msg.sender == owner);
        _;
    }
    
    modifier onlyOtherContract()
    {
        require(msg.sender == othercontractset || msg.sender == othercontractget);
        _;
    }
    
    function setOtherContract(address _adr1, address _adr2) onlyOwner payable public
    {
        othercontractset = _adr1;
        othercontractget = _adr2;
    }
    
    
    function addMake(string t, uint256 e) onlyOtherContract public
    {
        require(data[t][e].status == false);
        data[t][e].date = now;
        index[t][e] = listexam[t].push(e)-1;
        tuser[e] = t;
        data[t][e].status = true;
        existexam[e] = true;
    }
    
    function setAllAcceptGroupForExam(string t, uint256 e, uint256[] g, bool []acc) onlyOtherContract public
    {
        require(getStatusTeacherExam(t, e)==true);
        for (uint256 i = 0; i<g.length; i++)
        {
            data[t][e].accept[g[i]] = acc[i];
        }
    }
    
    function getAllAcceptGroupForExam(string t, uint256 e, uint256[] g, bool[] acc) public view returns(bool[])
    {
        require(getStatusTeacherExam(t, e) == true);
        for (uint256 i=0; i<g.length; i++)
        {
            acc[i] = data[t][e].accept[g[i]];
        }
        return acc;
    }
    
    function getAcceptGroupForExam(string t, uint256 e, uint256 g) public view returns(bool)
    {
        require(getStatusTeacherExam(t, e) == true);
        return data[t][e].accept[g];
    }
    
    function setAcceptGroupForExam(string t, uint256 e, uint256 g, bool acc) onlyOtherContract public
    {
        require(getStatusTeacherExam(t, e)==true);
        data[t][e].accept[g] = acc;
    }
    
    function deleteMake(string t, uint256 e) onlyOtherContract public
    {
        require(data[t][e].status == true);
        tuser[e] = "";
        for (uint256 i = index[t][e]+1; i<getLengthListExam(t); i++)
        {
            listexam[t][i-1] = listexam[t][i];
            index[t][listexam[t][i]]--;
        }
        listexam[t].length--;
        data[t][e].status = false;
        existexam[e] = false;
    }
    
    function getLengthListExam(string u) view public returns(uint256)
    {
        return listexam[u].length;
    }
    
    function getDate(string u, uint256 e) view public returns(uint256)
    {
        require(getStatusTeacherExam(u, e) == true);
        return data[u][e].date;
    }
    
    function getTeacherExam(uint256 e) view public returns(string)
    {
        require(examExistInMake(e) == true);
        
        return tuser[e];
    }
    
    function getAllIdExamTeacherMake(string u) view public returns(uint256[])
    {
        return listexam[u];
    }
    
    function getIdExamTeacherMake(string u, uint256 i) view public returns(uint256)
    {
        require(i>=0 && i<getLengthListExam(u));
        return listexam[u][i];
    }
    
    function getStatusTeacherExam(string u, uint256 e) view public returns(bool)
    {
        require(examExistInMake(e));

        return data[u][e].status;
    }
    
    function examExistInMake(uint256 u) view public returns(bool) 
    {
        return existexam[u];
    }
    
}
