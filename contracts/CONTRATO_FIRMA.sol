// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
contract REGISTRO {

    address private owner;
    
    constructor()  {
      owner = msg.sender;
      activeAccounts[owner]= true;
    }
    
    modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }
   
  
   mapping(address => bool) private activeAccounts;
   mapping(address => mapping(uint256 => bool)) usedNonces;
     
     
    function activateAccount(uint256 nonce,address addr,  bytes memory signature) public onlyOwner{
        
        require(!usedNonces[msg.sender][nonce],"ERROR NONCE");
        usedNonces[msg.sender][nonce] = true;

        // this recreates the message that was signed on the client
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,addr)));
        //bytes32 message = keccak256(abi.encodePacked(["uint256", "address", "address"],[nonce, msg.sender, addr]));
        
        

        require(recoverSigner(message, signature) == owner,"ERROR VERIFICAR FIRMA");

       activeAccounts[addr]= false;
   }
   
   
     function deactivateAccount(uint256 nonce, address addr,  bytes memory signature) public onlyOwner{
        
        require(!usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;

        // this recreates the message that was signed on the client
        bytes32 message = (keccak256(abi.encodePacked(nonce, msg.sender,addr)));

        require(recoverSigner(message, signature) == owner);

       activeAccounts[addr]= false;
   }

   function stateAccount(address addr)public view returns(bool){
       return activeAccounts[addr];
   }
   
   
   
   
    struct permission{
      
        bool read;
        bool update;
        bool del;
       
    }

    struct register {
        string code;
        string HasCachedAcl;
        string idRegister;
        uint256 IsRemoved;
        string Name;
        string Reference;
        string Schemas;
        address owner;
        mapping(address => bool) activeAcl;
        mapping(address => permission) acl;
    }
    
    
   
    struct Map {
        uint256[] keys;
        mapping(uint256 => uint) indexOf;
        mapping(uint256 => bool) inserted;
    }
    
   mapping (uint256 => register) private registers;
   mapping (uint256 => bool) private activeRegisters;
   
   
   mapping (uint256 => Map) private names;
   mapping (address => Map) private regPerAccount;
  
   
   function createRegister(uint256 nonce, string memory _code, string memory _HasCachedAcl, string memory _idRegister, 
   uint _IsRemoved, string memory _Name, string memory _Reference, string memory _Schemas,bytes memory signature) public{
       
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,_code, _HasCachedAcl,_idRegister, _IsRemoved
        ,_Name,_Reference,_Schemas)));

        require(recoverSigner(message, signature) == msg.sender);
        
        
       
        uint256 idHash = uint(keccak256(abi.encodePacked(_idRegister)));
        string memory nombre = upper(_Name);
        uint256 idHash2 = uint(keccak256(abi.encodePacked(nombre)));
        set(names[idHash2],idHash);
        
        activeRegisters[idHash]=true;
        
        registers[idHash].code=_code; 
        registers[idHash].HasCachedAcl=_HasCachedAcl;
        registers[idHash].IsRemoved=_IsRemoved;
        registers[idHash].Name=_Name;
        registers[idHash].Reference=_Reference; 
        registers[idHash].Schemas=_Schemas;
        registers[idHash].owner=msg.sender;
        registers[idHash].activeAcl[msg.sender]=true;
        registers[idHash].acl[msg.sender]=permission(true,true, true);
        registers[idHash].activeAcl[owner]=true;
        registers[idHash].acl[owner]=permission(true,true, true);

        set(regPerAccount[msg.sender], idHash);
       
        
    }
    
     function changePermissionToRegister(uint256 nonce, string memory idRegister, address user, bool read, bool update, 
     bool del, bytes memory signature)public {
         
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,idRegister,user, read,update, del)));

        require(recoverSigner(message, signature) == msg.sender);
        
        uint256 idHash = uint(keccak256(abi.encodePacked(idRegister)));
        
        require (registers[idHash].owner==msg.sender && user!=owner);
        registers[idHash].activeAcl[user]=true;
        registers[idHash].acl[user]=permission(read,update, del);
        
    
         
     }
    
    
    
    
      function searchById(uint256 nonce, string memory _abox,bytes memory signature) public returns(string memory) {
        
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,_abox)));

        require(recoverSigner(message, signature) == msg.sender);
        
        
        
        uint256 res = uint(keccak256(abi.encodePacked(_abox)));
        require(activeRegisters[res]);
    
        require (registers[res].activeAcl[msg.sender] && registers[res].acl[msg.sender].read);
        
        string memory output=registers[res].code;
        
        return  output;
        
    }
    
    
        
    function searchByName(uint256 nonce, string memory _Name,bytes memory signature ) public returns (string memory){
        
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,_Name)));

        require(recoverSigner(message, signature) == msg.sender);
        
        string memory nombre = upper(_Name);
        uint256 Nom = uint(keccak256(abi.encodePacked(nombre)));
        string memory salida = "";
        uint i;
        for (i= 0; i<size(names[Nom]); i++){
            uint256 idReg = getKeyAtIndex(names[Nom], i);
            if (activeRegisters[idReg]){
                 
                if (registers[idReg].activeAcl[msg.sender] && registers[idReg].acl[msg.sender].read){
                   salida = registers[idReg].idRegister;
                 }
            }
        }
        
        return salida;
    }
    
    function updateRegister(uint256 nonce, string memory _code, string memory _HasCachedAcl, 
    string memory _idRegistro, uint _IsRemoved, string memory _Name, string memory _Reference,
    string memory _Schemas, bytes memory signature) public{
         
         
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,_code, _HasCachedAcl,_idRegistro, _IsRemoved
        ,_Name,_Reference,_Schemas)));


        require(recoverSigner(message, signature) == msg.sender);
         
         uint256 idHash = uint(keccak256(abi.encodePacked(_idRegistro)));
        
        require(activeRegisters[idHash]);
        
        require(registers[idHash].acl[msg.sender].update);
    
        registers[idHash].code=_code; 
        registers[idHash].HasCachedAcl=_HasCachedAcl;
        registers[idHash].IsRemoved=_IsRemoved;
        registers[idHash].Reference=_Reference; 
        registers[idHash].Schemas=_Schemas;
        uint256 idHash3 = uint(keccak256(abi.encodePacked(registers[idHash].Name)));
        remove(names[idHash3], idHash);
        uint256 idHash4 = uint(keccak256(abi.encodePacked(_Name)));
        set(names[idHash4],idHash);
        registers[idHash].Name=_Name; 
            
      
    }
    function deleteRegister(uint256 nonce, string memory _idRegister, bytes memory signature) public{
        
        require(activeAccounts[msg.sender] && !usedNonces[msg.sender][nonce]);
        usedNonces[msg.sender][nonce] = true;
        
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, msg.sender,_idRegister)));

        require(recoverSigner(message, signature) == msg.sender);
        
        
        
        uint256 idHash = uint(keccak256(abi.encodePacked(_idRegister)));
        require(activeRegisters[idHash]);
        
        require ( registers[idHash].activeAcl[msg.sender] &&  registers[idHash].acl[msg.sender].del);
        
        
        
        string memory nombre = upper(registers[idHash].Name);
        uint256 idHash2 = uint(keccak256(abi.encodePacked(nombre)));
        remove(names[idHash2], idHash);
        
        remove(regPerAccount[registers[idHash].owner], idHash);
        activeRegisters[idHash]=false;
        
        
    }
    
    
 


    function getKeyAtIndex(Map storage map, uint index) private view returns (uint256) {
        return map.keys[index];
    }

    function size(Map storage map) private view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        uint256 key
    ) private {
        if (! map.inserted[key]) {
            
            map.inserted[key] = true;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, uint256 key) private {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        uint256 lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }


    
    function upper(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }
    
    function _upper(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1) - 32);
        }

        return _b1;
    }
    
    
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}