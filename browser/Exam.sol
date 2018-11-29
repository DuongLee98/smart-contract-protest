pragma solidity ^0.4.11;
import "browser/Account.sol";
import "browser/Make.sol";

contract Exam
{
    struct time
    {
        uint256 start;
        uint256 end;
        bool setstart;
        bool setend;
    }
    
    mapping(uint256 => string) name;
    mapping(string => uint256) eid;
    
    mapping(uint256 => bool) existid;
    mapping(string => bool) existname;
    
    uint256 [] listid;
    mapping(uint256 => uint256) indexid;
    
    uint256 staticid = 10000;
    
    mapping(uint256 => string) etype;
    mapping(uint256 => string[]) question;
    mapping(uint256 => mapping(uint256 => string[])) selection;
    mapping(uint256 => uint256[]) answer;
    mapping(uint256 => time) timedo;
    mapping(uint256 => bool) epublic;
    
    mapping(uint256 => mapping(string => uint8[])) result;
    
    modifier teacherAccess(string tuser, string pass, uint256 id)
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(existIdExam(id));
        require(m.getStatusTeacherExam(tuser, id));
        require(!existTimeEndOfExam(id) || !existTimeStartOfExam(id) || now < getTimeStartOfExam(id));
        _;
    }
    
    Account acc;
    Make m;
    
    constructor () public
    {
        owner = msg.sender;
        acc = Account(0xE50ad55eE3F4E1A3F50b8d1617c3edaCFd4eF1Bc);
        m = Make(0xAF67Ca3723Bf84D43646411009E926b4dE88c285);
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
    
    function addExam(string n) onlyOtherContract public
    {
        require(existname[n]==false);
        
        name[staticid] = n;
        eid[n] = staticid;
        
        existid[staticid] = true;
        existname[n] = true;
        
        indexid[staticid] = listid.push(staticid) - 1;
        staticid++;
    }
    
    function getLengthExam() public view returns(uint256)
    {
        return listid.length;
    }
    
    function getIdExam(uint256 i) public view returns(uint256)
    {
        require (i>=0 && i<getLengthExam());
        return listid[i];
    }
    
    function getAllIdExam() public view returns(uint256 [])
    {
        return listid;
    }
    
    function getNameOfExam(uint256 id) public view returns(string)
    {
        require(existid[id]==true);
        return name[id];
    }
    
    function getIdOfExam(string n) public view returns(uint256)
    {
        require(existname[n]==true);
        return eid[n];
    }
    
    function existIdExam(uint256 id) public view returns(bool)
    {
        return existid[id];
    }
    
    function existNameExam(string n) public view returns(bool)
    {
        return existname[n];
    }
    
    function deleteExam(uint256 id) onlyOtherContract public
    {
        require(existid[id]==true);
        existname[name[id]] =  false;
        existid[id] = false;
        
        for(uint256 i = indexid[id]+1; i<listid.length; i++)
        {
            listid[i-1] = listid[i];
            indexid[listid[i-1]]--;
        }
        listid.length--;
    }
    
    function setGeneralExam(string tuser, string pass, uint256 id, uint256 timeS, uint256 timeE, string subject, bool p) teacherAccess(tuser, pass, id) public payable
    {
        require(timeS<timeE);
        setTimeStartOfExam(id, timeS);
        setTimeEndOfExam(id, timeE);
        setTypeOfExam(id, subject);
        setPublicOfExam(id, p);
    }
    
    function editNameExam(string tuser, string pass, uint256 id, string nn) teacherAccess(tuser, pass, id) payable public
    {
        require(existid[id] == true);
        require(existname[nn] == false);
        existname[name[id]] = false;
        name[id] = nn;
        eid[nn] = id;
        existname[nn] = true;
    }
    
    function getLengthQuestionOfExam(uint256 id) public view returns(uint256)
    {
        require(existIdExam(id));
        return question[id].length;
    }
    
    function getQuestionOfExam(uint256 id, uint256 i) onlyOtherContract public view returns(string)
    {
        require(existid[id] == true);
        require(i>=0 && i<getLengthQuestionOfExam(id));
        return question[id][i];
    }
    
    function addOrSetQuestionOfExam(string tuser, string pass, uint256 id, uint256 i, string nq) teacherAccess(tuser, pass, id) public payable
    {
        require(existid[id]==true);
        if(i>=0 && i<getLengthQuestionOfExam(id))
        {
            question[id][i] = nq;
        }
        else
        {
            require(i == getLengthQuestionOfExam(id));
            question[id].push(nq);
        }
    }
    
    function setLengthQuestionOfExam(string tuser, string pass, uint256 id, uint256 len) teacherAccess(tuser, pass, id) public payable
    {
        require(existid[id] == true);
        question[id].length = len;
    }
    
    function existQuestionOfExam(uint256 id, uint256 s) public view returns(bool)
    {
        require(existIdExam(id) == true);
        if(s<0 || s>=getLengthQuestionOfExam(id))
            return false;
        return true;
    }
    
    function getLengthSelectionOfQuestionInExam(uint256 id, uint256 q) public view returns(uint256)
    {
        require(existQuestionOfExam(id, q));
        return selection[id][q].length;
    }
    
    function existSelectionOfQuestionInExam(uint256 id, uint256 q, uint256 s) public view returns(bool)
    {
        if (existQuestionOfExam(id, q) == false)
            return false;
        if (s<0 || s>= getLengthSelectionOfQuestionInExam(id, q))
            return false;
        return true;
    }
    
    function getSelectionOfQuestionInExam(uint256 id, uint256 q, uint256 s) onlyOtherContract public view returns(string)
    {
        require(existSelectionOfQuestionInExam(id, q, s));
        return selection[id][q][s];
    }
    
    function addOrSetSelectionOfQuestionInExam(string tuser, string pass, uint256 id, uint256 q, uint256 s, string ns) teacherAccess(tuser, pass, id) public payable
    {
        require(existQuestionOfExam(id, q));
        if(s>=0 && s<getLengthSelectionOfQuestionInExam(id, q))
        {
            selection[id][q][s] = ns;
        }
        else
        {
            require(s == getLengthSelectionOfQuestionInExam(id, q));
            selection[id][q].push(ns);
        }
    }
    
    function setLengthSelectionOfQuestionInExam(string tuser, string pass, uint256 id, uint256 q, uint256 l) teacherAccess(tuser, pass, id) public payable
    {
        require(existQuestionOfExam(id, q));
        selection[id][q].length = l;
    }
    
    function getAnswerOfExam(uint256 id, uint256 i) onlyOtherContract public view returns(uint256)
    {
        require(existid[id] == true);
        require(i>=0 && i<getLengthAnswerOfExam(id));
        return answer[id][i];
    }
    
    function getLengthAnswerOfExam(uint256 id) public view returns(uint256)
    {
        return answer[id].length;
    }
    
    function getAllAnswerOfExam(uint256 id) onlyOtherContract public view returns(uint256 [])
    {
        require(existid[id] == true);
        return answer[id];
    }
    
    function addOrSetAnswerOfExam(string tuser, string pass, uint256 id, uint256 i, uint256 aw) teacherAccess(tuser, pass, id) public payable
    {
        require(existid[id]==true);
        require(aw>=0 && aw<getLengthSelectionOfQuestionInExam(id, i));
        if(i>=0 && i<getLengthAnswerOfExam(id))
        {
            answer[id][i] = aw;
        }
        else
        {
            require(i == getLengthAnswerOfExam(id));
            answer[id].push(aw);
        }
    }
    
    function addOrSetAllAnswerOfExam(string tuser, string pass, uint256 id, uint256[] aw) teacherAccess(tuser, pass, id) public payable
    {
        require(existid[id] == true);
        answer[id] = aw;
    }
    
    function setLengthAnswerOfExam(string tuser, string pass, uint256 id, uint256 len) teacherAccess(tuser, pass, id) public payable
    {
        require(existid[id] == true);
        answer[id].length = len;
    }
    
    function existTimeStartOfExam(uint256 id) public view returns(bool)
    {
        require(existIdExam(id));
        return timedo[id].setstart;
    }
    
    function existTimeEndOfExam(uint256 id) public view returns(bool)
    {
        require(existIdExam(id));
        return timedo[id].setend;
    }
    
    function getTimeStartOfExam(uint256 id) public view returns(uint256)
    {
        require(existTimeStartOfExam(id)==true);
        require(existid[id] == true);
        return timedo[id].start;
    }
    
    function getTimeEndOfExam(uint256 id) public view returns(uint256)
    {
        require(existTimeEndOfExam(id)==true);
        require(existid[id] == true);
        return timedo[id].end;
    }
    
    function setTimeStartOfExam(uint256 id, uint256 t) internal
    {
        require(existIdExam(id));
        timedo[id].start = t;
        timedo[id].setstart = true;
    }
    
    function setTimeEndOfExam(uint256 id, uint256 t) internal
    {
        require(existIdExam(id));
        timedo[id].end = t;
        timedo[id].setend = true;
    }
    
    function getPublicOfExam(uint256 id) public view returns(bool)
    {
        require(existIdExam(id));
        return epublic[id];
    }
    
    function setPublicOfExam(uint256 id, bool p) internal
    {
        require(existIdExam(id));
        epublic[id] = p;
    }
    
    function getTypeOfExam(uint256 id) public view returns(string)
    {
        require(existIdExam(id));
        return etype[id];
    }
    
    function setTypeOfExam(uint256 id, string tp) internal
    {
        require(existIdExam(id));
        etype[id] = tp;
    }
}
