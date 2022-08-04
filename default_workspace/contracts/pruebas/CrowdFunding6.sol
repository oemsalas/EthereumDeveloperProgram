// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {

    struct Contribution {
        address contributor;
        uint amount;
    }

    enum Status { Active, Inactive }
    struct Project {
        string id;
        string name;
        string description;
        uint fundraisingGoal;
        address payable wallet;
        address owner;
        uint funds;
        Status status;
    }

    Project project;
    Project[] public projectCluster;
    
    mapping(string => Contribution[]) public contributions;
    uint private initialFunds = 0;
    
    event NewFundNotification(address sender, uint fundAmount);
    
    event NewStatusChange(Status newStatus);

    modifier ownerNotSendFunds() {
        require(project.owner != msg.sender, "Owners shouldnt send funds to its own projects!");
        _;
    }

    modifier onlyOwnerModifyStates() {
         require(project.owner == msg.sender, "You must be the project owner!");
         _;
    }

    constructor(string memory _id, string memory _name, string memory _description, uint _fundraisingGoal) {
        project = Project(
            _id,
            _name,
            _description,
            _fundraisingGoal,
            payable(msg.sender),
            msg.sender,
            initialFunds,
            Status.Active
        );
        projectCluster.push(project);
    }

    function createProject(string memory _id, string memory _name, string memory _description, uint _fundraisingGoal) public {
        project = Project(
            _id,
            _name,
            _description,
            _fundraisingGoal,
            payable(msg.sender),
            msg.sender,
            initialFunds,
            Status.Active
        );
        projectCluster.push(project);
    }

    function fundProject(uint index) public payable ownerNotSendFunds {
        Project memory project = projectCluster[index];
        require(project.status == Status.Active, "This project state is Closed!");
        require(msg.value > 0, "Funds can not be Zero!");

        project.wallet.transfer(msg.value);
        project.funds += msg.value;
        projectCluster[index] = project;
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        emit NewFundNotification(msg.sender, msg.value);
    }

    function changeProjectStatus(Status newStatus) public onlyOwnerModifyStates {
        require(project.status != newStatus, "Project has that state already, choose another!");
        project.status = newStatus;
        emit NewStatusChange(newStatus);
    }

}