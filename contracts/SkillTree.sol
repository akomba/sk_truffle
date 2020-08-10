pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
//import "@nomiclabs/buidler/console.sol";

contract SkillTree is Ownable {
  address public admin;

  constructor(address _admin) public {
    admin = _admin;
    //console.log("Skilltree app admin is:",_admin);
  }   

  /* =========================================
    Users
  
    Settings bits
    0: issuer
    1: expert
  ========================================= */
  
  struct userStruct {
    string  name;
    bytes   other_info;  // ipfs hash?
    bool    is_issuer;
    bool    is_expert;
    uint    state;
  }

  /*
     User.state
     0: nonexistent
     1: needs_approval
     2: active
     3: disabled
  */

  address[]  private userArray;
  mapping (address => userStruct) private userMap;

  event UserChanged(address user,string name,bool is_issuer,bool is_expert,bytes other_info);
  
  function update_user(address _address, string calldata _name, bytes calldata _other_info, bool _is_issuer, bool _is_expert) external {
    require((msg.sender == _address), "Only owner can update");
    require((userMap[_address].state > 0), "Create user first");
    
    userMap[_address].name       = _name;
    userMap[_address].other_info = _other_info;
    userMap[_address].is_issuer  = _is_issuer;
    userMap[_address].is_expert  = _is_expert;
    userMap[_address].state      = 1; // after any change user needs to be approved. This is not flexible enough. Will need to improve. 
      
    emit UserChanged(_address, _name, _is_issuer, _is_expert, _other_info);
  }
    
  event NewUser(address user,string name,bool is_issuer,bool is_expert,bytes other_info);
 
  function sign_up(string calldata _name, bytes calldata _other_info, bool _is_issuer, bool _is_expert) external {
    address _address = msg.sender;
    require((userMap[_address].state == 0), "This user already exists");
   
    userMap[_address] = userStruct(_name, _other_info, _is_issuer, _is_expert, 1); 
    userArray.push(_address);
    emit NewUser(_address, _name, _is_issuer, _is_expert, _other_info);
  }

  /*
  function add_user(address _address, string calldata _name, bytes calldata _other_info, int _is_issuer, int _is_expert) external {
    require((userMap[_address].state == 0), "This user already exists");
   
    bool is_issuer = (_is_issuer == 0 ? false : true);
    bool is_expert = (_is_expert == 0 ? false : true);
    
    userMap[_address] = userStruct(_name, _other_info, is_issuer, is_expert, 1); 
    userArray.push(_address);
    emit NewUser(_address, _name, is_issuer, is_expert, _other_info);
  }
  */
    
  function number_of_users() public view returns (uint256) {
    return userArray.length;
  }

  // get user by position
  //function get_user_by_position(uint position) public view returns ( string memory ) {
  //  require((userArray.length > position), "No user at that position");
  //  return(userMap[userArray[position]]);
  //}

  // get user by address
  function get_user(address _address) public view returns (userStruct memory) {
    require((userMap[_address].state > 0), "No user with that address");
    return(userMap[_address]);
  }
  
  // Determining user type
  function is_expert(address _address) public view returns (bool) {
    require((userMap[_address].state > 0), "No user with that address");
    return(userMap[_address].is_expert);
  }

  function is_issuer(address _address) public view returns (bool) {
    require((userMap[_address].state > 0), "No user with that address");
    return(userMap[_address].is_issuer);
  }

  //
  // Admin functions
  //

  function approve_user(address _address) public{
    require((msg.sender == admin), "Only admin can approve");
    require((userMap[_address].state == 1), "This user does not need approving");
    userMap[_address].state = 2;
  }
}
