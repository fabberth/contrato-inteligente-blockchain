// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract registrosAbox {
    uint256 public counter = 0;
    
    struct registro {
        uint256 id;
        string code;
        string HasCachedAcl;
        string idRegistro;
        uint256 IsRemoved;
        string Name;
        string Reference;
        string Schemas;
    }

    struct Map {
        uint256[] keys;
        mapping(uint256 => uint) indexOf;
        mapping(uint256 => bool) inserted;
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
    mapping (uint256 => registro) public registros;
    
    mapping (uint256 => Map) private nombres;
    
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
  

    function createRegistro(string memory _code, string memory _HasCachedAcl, string memory _idRegistro, uint _IsRemoved, string memory _Name, string memory _Reference, string memory _Schemas) public{
        uint256 idHash = uint(keccak256(abi.encodePacked(_idRegistro)));
        string memory nombre = upper(_Name);
        uint256 idHash2 = uint(keccak256(abi.encodePacked(nombre)));
        
        if (registros [idHash].id > 0){
            revert('ya existe el id');
        }
        set(nombres[idHash2],idHash);
        registros[idHash] = registro(idHash, _code, _HasCachedAcl, _idRegistro, _IsRemoved, _Name, _Reference,_Schemas);
    }
    
    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length +
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
    
    function buscarPorNombre(string memory _Name) public view returns (string memory){
        string memory nombre = upper(_Name);
        uint256 Nom = uint(keccak256(abi.encodePacked(nombre)));
        string memory salida = "";
        uint i;
        for (i= 0; i<size(nombres[Nom]); i++){
            uint256 llave = getKeyAtIndex(nombres[Nom], i);
            salida = concat(concat(salida,";"),registros[llave].idRegistro);
        }
        
        return salida;
    }
    
    

    function buscarRegristroPorId(string memory _abox) public view returns(registro memory) {
        
        uint256 Res = uint(keccak256(abi.encodePacked(_abox)));
        registro memory re = registros[Res];
        return re;
        
    }
    
    function actualizarRegistro(string memory _code, string memory _HasCachedAcl, string memory _idRegistro, uint _IsRemoved, string memory _Name, string memory _Reference, string memory _Schemas) public{
        uint256 idHash = uint(keccak256(abi.encodePacked(_idRegistro)));
        
        if (registros [idHash].id > 0){
            
            //registros[idHash] = registro(idHash, _code, _HasCachedAcl, _idRegistro, _IsRemoved, _Name, _Reference,_Schemas);
            registros[idHash].code=_code; 
            registros[idHash].HasCachedAcl=_HasCachedAcl;
            registros[idHash].IsRemoved=_IsRemoved;
            registros[idHash].Reference=_Reference; 
            registros[idHash].Schemas=_Schemas;
            uint256 idHash3 = uint(keccak256(abi.encodePacked(registros[idHash].Name)));
            
            remove(nombres[idHash3], idHash);
            uint256 idHash4 = uint(keccak256(abi.encodePacked(_Name)));
            set(nombres[idHash4],idHash);
            registros[idHash].Name=_Name; 
            
            
        } else {
            revert('no exite registro ');
        }
        
    }
    function borrarRegistro(string memory _idRegistro) public{
        uint256 idHash = uint(keccak256(abi.encodePacked(_idRegistro)));
        
        if (registros [idHash].id > 0){
            registros[idHash] = registro(0, "", "", "", 0, "", "","");
        } else {
            revert('no exite registro ');
        }
        
    }

}