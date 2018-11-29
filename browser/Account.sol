pragma solidity ^0.4.11;
import "browser/Student.sol";
import "browser/Teacher.sol";

contract Account is Student, Teacher
{
    function regStudent(string user, string pass, string name, string phone) public payable
    {
        bool existS = userSExist(user);
        bool existT = userTExist(user);
        require(!existS && !existT);
        addSUser(user, pass, name, phone);
    }
    
    function regTeacher(string user, string pass, string name, string phone, string ic) public payable
    {
        bool existS = userSExist(user);
        bool existT = userTExist(user);
        require(!existS && !existT);
        addTUser(user, pass, phone, name, ic);
    }
    
    function login(string user, string pass) public view returns(bool, string, uint256)
    {
        if (userSExist(user) == true && compareStringS(getPassSUser(user), pass)==true)
            return (true, "student", 0);
        else if (userTExist(user) == true && compareStringT(getPassTUser(user), pass)==true)
            return (true, "teacher", 1);
        return (false, "none", 2);
    }
}
