pragma solidity ^0.4.11;
import "browser/Group.sol";
import "browser/Manage.sol";
import "browser/Join.sol";
import "browser/Account.sol";
contract ManageGroup
{
    Account acc;
    Group gr;
    Manage mn;
    Join jn;
    constructor() public
    {
        acc = Account(0xE50ad55eE3F4E1A3F50b8d1617c3edaCFd4eF1Bc);
        gr = Group(0x9376871a993Bfa8800BE196c2c93c1809db9b823);
        mn = Manage(0x5c91641Bb07A53a7aEE3740b05EC737428C15fE7);
        jn = Join(0x70BaC1C4D61A0ad10a494448e5D310a118e62a50);
    }
    function createGroupByTeacher(string tuser, string pass, string gname) payable public
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        gr.addGroup(gname);
        uint256 gid = gr.getIdNameGroup(gname);
        mn.addManage(tuser, gid);
    }
    function deleteGroupByTeacher(string tuser, string pass, uint256 gid) payable public
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(gr.existIdGroup(gid));
        require(mn.getStatus(tuser, gid)==true);
        mn.deleteManage(tuser, gid);
        gr.deleteGroup(gid);
        jn.deleteAllUserInGroup(gid);
    }
    function editGroupByTeacher(string tuser, string pass, uint256 gid, string nm) payable public
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(gr.existIdGroup(gid));
        require(mn.getStatus(tuser, gid)==true);
        gr.editGroup(gid, nm);
    }
    function groupAddOrInviteStudentByTeacher(string tuser, string pass, uint256 gid, string suser) payable public
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(gr.existIdGroup(gid));
        require(mn.getStatus(tuser, gid)==true);
        require(acc.userSExist(suser));
        jn.groupAddUser(suser, gid);
    }
    function groupDeleteOrRefuseStudentByTeacher(string tuser, string pass, uint256 gid, string suser) payable public
    {
        (bool lg, , uint256 t) = acc.login(tuser, pass);
        require(lg==true && t==1);
        require(gr.existIdGroup(gid));
        require(mn.getStatus(tuser, gid)==true);
        require(acc.userSExist(suser));
        jn.groupRefuseUser(suser, gid);
    }

    function studentJoinOrAcceptGroup(string suser, string pass, uint256 gid) payable public
    {
        (bool lg, , uint256 t) = acc.login(suser, pass);
        require(lg==true && t==0);
        require(gr.existIdGroup(gid));
        require(acc.userSExist(suser));
        jn.userJoinGruop(suser, gid);
    }
    function studentExitOrRefuseGroup(string suser, string pass, uint256 gid) payable public
    {
        (bool lg, , uint256 t) = acc.login(suser, pass);
        require(lg==true && t==0);
        require(gr.existIdGroup(gid));
        require(acc.userSExist(suser));
        jn.userRefuseGroup(suser, gid);
    }
}
