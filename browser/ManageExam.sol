pragma solidity ^0.4.11;
import "browser/Account.sol";
import "browser/Exam.sol";
import "browser/Do.sol";
import "browser/Make.sol";
import "browser/Join.sol";
import "browser/Manage.sol";

contract ManageExamSet
{
    Account acc;
    Exam e;
    Do d;
    Make m;
    Join j;
    Manage mn;
    constructor() public
    {
        acc = Account(0xE50ad55eE3F4E1A3F50b8d1617c3edaCFd4eF1Bc);
        e = Exam(0x86847AA2Efb2581a7B2F4f7F22284545e000AEc6);
        d = Do(0x3F13163584c690b73eE5Dbb2aA715365313AA88f);
        m = Make(0xAF67Ca3723Bf84D43646411009E926b4dE88c285);
        j = Join(0x70BaC1C4D61A0ad10a494448e5D310a118e62a50);
        mn = Manage(0x5c91641Bb07A53a7aEE3740b05EC737428C15fE7);
    }
    
    modifier teacherAccess(string tuser, string pass, uint256 eid)
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(e.existIdExam(eid));
        require(m.getStatusTeacherExam(tuser, eid));
        require(!e.existTimeEndOfExam(eid) || !e.existTimeStartOfExam(eid) || now < e.getTimeStartOfExam(eid));
        _;
    }
    
    modifier studentAccess(string suser, string pass, uint256 eid)
    {
        (bool lg, , uint256 t) = acc.login(suser, pass);
        require(lg==true && t==0);
        require(e.existIdExam(eid));
        require(d.getStatusInDo(suser, eid)==false);
        require(e.existTimeEndOfExam(eid) && e.existTimeStartOfExam(eid));
        require(now >= e.getTimeStartOfExam(eid) && now <= e.getTimeEndOfExam(eid));
        _;
    }
    
    function createExamByTeacher(string tuser, string pass, string ename) public payable
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        e.addExam(ename);
        uint256 eid = e.getIdOfExam(ename);
        m.addMake(tuser, eid);
    }
    
    function doExamByStudent(string suser, string pass, uint256 eid, int256 [] aw) studentAccess(suser, pass, eid) payable public
    {
        if (e.getPublicOfExam(eid) == false)
        {
            string memory tuser = m.getTeacherExam(eid);
            string memory susert = suser;
            
            for (uint256 i = 0; i<j.getLengthJGroup(susert); i++)
            {
                if (m.getAcceptGroupForExam(tuser, eid, j.getJGroup(susert, i)) == true && j.getJStatus(susert, j.getJGroup(susert, i))==1)
                {
                    uint256 diem1 = compareAnswer(aw, e.getAllAnswerOfExam(eid));
                    d.add(suser, eid, diem1, aw);
                    break;
                }
            }
        }
        else
        {
            uint256 diem2 = compareAnswer(aw, e.getAllAnswerOfExam(eid));
            d.add(suser, eid, diem2, aw);
        }
    }
    
    function compareAnswer(int256 [] aw, uint256 []qs) public pure returns(uint256)
    {
        uint256 ac = 0;
        require(aw.length == qs.length);
        for (uint256 i = 0; i<aw.length; i++)
        {
            if (aw[i] >= 0)
            {
                if (uint(aw[i]) == qs[i])
                {
                    ac++;
                }
            }
        }
        return ac;
    }
    
    function deleteExamByTeacher(string tuser, string pass, uint256 eid) teacherAccess(tuser, pass, eid) public payable
    {
        m.deleteMake(tuser, eid);
        e.deleteExam(eid);
    }
    
    function setAcceptGroupForExam(string tuser, string pass, uint256 eid, uint256 gid, bool ac) teacherAccess(tuser, pass, eid) public payable
    {
        require(mn.getStatus(tuser, gid));
        m.setAcceptGroupForExam(tuser, eid, gid, ac);
    }
    
    function setAllAcceptGroupForExam(string tuser, string pass, uint256 eid, uint256 [] gid, bool [] ac) teacherAccess(tuser, pass, eid) public payable
    {
        require(gid.length == ac.length);
        for(uint256 i=0; i<gid.length; i++)
        {
            require(mn.getStatus(tuser, gid[i]));
        }
        
        m.setAllAcceptGroupForExam(tuser, eid, gid, ac);
    }
}

contract ManageExamGet
{
    Account acc;
    Exam e;
    Do d;
    Make m;
    Join j;
    constructor() public
    {
        acc = Account(0xE50ad55eE3F4E1A3F50b8d1617c3edaCFd4eF1Bc);
        e = Exam(0x86847AA2Efb2581a7B2F4f7F22284545e000AEc6);
        d = Do(0x3F13163584c690b73eE5Dbb2aA715365313AA88f);
        m = Make(0xAF67Ca3723Bf84D43646411009E926b4dE88c285);
        j = Join(0x70BaC1C4D61A0ad10a494448e5D310a118e62a50);
    }
    
    function getAllAnswerOfExam(string user, string pass, uint256 eid) public view returns(uint256[])
    {
        (bool lg, , uint256 t) = acc.login(user, pass);
        require(lg == true);
        require(t==0 || t==1);
        if (t==1)
        {
            bool tmp = false;
            if(m.getStatusTeacherExam(user, eid))
                tmp = true;
            else if(e.getPublicOfExam(eid)==true && now > e.getTimeEndOfExam(eid))
                tmp = true;
            require(tmp);
            return e.getAllAnswerOfExam(eid);
        }
        else
        {
            require(now > e.getTimeEndOfExam(eid));
            if (e.getPublicOfExam(eid) == false)
            {
                if (d.getStatusInDo(user, eid)==true)
                {
                    return e.getAllAnswerOfExam(eid);
                }
                else
                {
                    string memory tuser = m.getTeacherExam(eid);
                    uint256 [] memory arr = j.getAllGroupOfUser(user);
                    for (uint256 i = 0; i<arr.length; i++)
                    {
                        if (m.getAcceptGroupForExam(tuser, eid, arr[i]) == true && j.getJStatus(user, arr[i])==1)
                        {
                            return e.getAllAnswerOfExam(eid);
                        }
                    }
                }
            }
            else
            {
                return e.getAllAnswerOfExam(eid);
            }
            require(false);
        }
    }
    
    function getAnswerOfExam(string user, string pass, uint256 eid, uint256 i) public view returns(uint256)
    {
        (bool lg, , uint256 t) = acc.login(user, pass);
        require(lg == true);
        require(t==0 || t==1);
        if (t==1)
        {
            bool tmp = false;
            if(m.getStatusTeacherExam(user, eid))
                tmp = true;
            else if(e.getPublicOfExam(eid)==true && now > e.getTimeEndOfExam(eid))
                tmp = true;
            require(tmp);
            return e.getAnswerOfExam(eid, i);
        }
        else
        {
            require(now > e.getTimeEndOfExam(eid));
            if (e.getPublicOfExam(eid) == false)
            {
                if (d.getStatusInDo(user, eid)==true)
                {
                    return e.getAnswerOfExam(eid, i);
                }
                else
                {
                    string memory tuser = m.getTeacherExam(eid);
                    uint256 [] memory arr = j.getAllGroupOfUser(user);
                    for (uint256 ic = 0; ic<arr.length; ic++)
                    {
                        if (m.getAcceptGroupForExam(tuser, eid, arr[ic]) == true && j.getJStatus(user, arr[ic])==1)
                        {
                            return e.getAnswerOfExam(eid, i);
                        }
                    }
                }
            }
            else
            {
                return e.getAnswerOfExam(eid, i);
            }
            require(false);
        }
    }
    
    function getQuestionOfExam(string user, string pass, uint256 eid, uint256 i) public view returns(string)
    {
        (bool lg, , uint256 t) = acc.login(user, pass);
        require(lg == true);
        require(t==0 || t==1);
        if (t==1)
        {
            bool tmp = false;
            if(m.getStatusTeacherExam(user, eid))
                tmp = true;
            else if(e.getPublicOfExam(eid)==true)
                tmp = true;
            require(tmp);
            return e.getQuestionOfExam(eid, i);
        }
        else
        {
            require(now >= e.getTimeStartOfExam(eid));
            if (e.getPublicOfExam(eid) == false)
            {
                if (d.getStatusInDo(user, eid)==true)
                {
                    return e.getQuestionOfExam(eid, i);
                }
                else
                {
                    string memory tuser = m.getTeacherExam(eid);
                    uint256 [] memory arr = j.getAllGroupOfUser(user);
                    for (uint256 ic = 0; ic<arr.length; ic++)
                    {
                        if (m.getAcceptGroupForExam(tuser, eid, arr[ic]) == true && j.getJStatus(user, arr[ic])==1)
                        {
                            return e.getQuestionOfExam(eid, i);
                        }
                    }
                }
            }
            else
            {
                return e.getQuestionOfExam(eid, i);
            }
            require(false);
        }
    }
    
    function getSelectionOfQuestionInExam(string user, string pass, uint256 eid, uint256 q, uint256 s) public view returns(string)
    {
        (bool lg, , uint256 t) = acc.login(user, pass);
        require(lg == true);
        require(t==0 || t==1);
        if (t==1)
        {
            bool tmp = false;
            if(m.getStatusTeacherExam(user, eid))
                tmp = true;
            else if(e.getPublicOfExam(eid)==true)
                tmp = true;
            require(tmp);
            return e.getSelectionOfQuestionInExam(eid, q, s);
        }
        else
        {
            require(now >= e.getTimeStartOfExam(eid));
            if (e.getPublicOfExam(eid) == false)
            {
                if (d.getStatusInDo(user, eid)==true)
                {
                    return e.getSelectionOfQuestionInExam(eid, q, s);
                }
                else
                {
                    string memory tuser = m.getTeacherExam(eid);
                    uint256 [] memory arr = j.getAllGroupOfUser(user);
                    for (uint256 ic = 0; ic<arr.length; ic++)
                    {
                        if (m.getAcceptGroupForExam(tuser, eid, arr[ic]) == true && j.getJStatus(user, arr[ic])==1)
                        {
                            return e.getSelectionOfQuestionInExam(eid, q, s);
                        }
                    }
                }
            }
            else
            {
                return e.getSelectionOfQuestionInExam(eid, q, s);
            }
            require(false);
        }
    }
    
    function getTimeStamp() public view returns(uint256)
    {
        return now;
    }
}
