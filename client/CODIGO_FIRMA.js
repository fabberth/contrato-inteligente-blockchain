
const { default: SHA3 } = require('sha3');
const Web3 = require('web3')
var web3 = new Web3(Web3.givenProvider || 'ws://some.local-or-remote.node:7545');
app = {
    contracts: {},

    init: async () => {
        console.log('Ethereum')
        await app.loadEthereum()
        await app.loadAccount()
        await app.loadContracts()
        await app.render()
    },

    loadEthereum: async () =>{
        if (window.ethereum){

            app.web3Provider = window.ethereum
            await window.ethereum.request({method: 'eth_requestAccounts'});

        } else if (window.web3) {
           wweb3 = new Web3(window.web3.currentProvider)
        }
        else{
            console.log('instalar metamask')
        }
    },
    loadAccount: async () =>{
        const cuentas = await window.ethereum.request({method: 'eth_requestAccounts'});
        app.account = cuentas[0]
    },

    /*loadContracts: async () => {
        const  res = await fetch("registrosAbox.json")
        const registrosAboxJSON = await res.json()

        app.contracts.registrosAbox = TruffleContract(registrosAboxJSON)

        app.contracts.registrosAbox.setProvider(app.web3Provider)

        //app.registrosAbox = await app.contracts.registrosAbox.deployed()
        app.registrosAbox = await app.contracts.registrosAbox.deployed()

    },*/
    loadContracts: async () => {
        const  res = await fetch("REGISTRO.json")
        const registrosAboxJSON = await res.json()

        app.contracts.REGISTRO = TruffleContract(registrosAboxJSON)

        app.contracts.REGISTRO.setProvider(app.web3Provider)

        //app.registrosAbox = await app.contracts.registrosAbox.deployed()
        app.REGISTRO = await app.contracts.REGISTRO.deployed()

    },
    
    render: ()=> {
        console.log(app.account)
        document.getElementById('mostar').innerText = app.account
    },
    activarCuenta: async() =>{

        //var  count =  web3 . eth . getTransactionCount ( "0x26..." );
        var nonce = Math.floor(Math.random()*1001);
        nonce = 584866486;
        console.log('numero ramdon: '+nonce)

        const cuenta = app.account
        //const key = 'ff6b63185b1211d6208fec7e5d6c1a04ec76626ac8847363aafd0c31513d3d59';
        //var sender = app.account;
        console.log('cuenta2: '+cuenta);

        //var hash = web3.utils.sha3(nonce, cuenta, cuenta).toString("hex");
        const hash = web3.utils.soliditySha3(nonce,cuenta,cuenta).toString("hex");

        const contrato = web3.utils.soliditySha3("\x19Ethereum Signed Message:\n32", hash,);
        console.log("contrato: "+contrato);

        console.log('mensaje hash: '+hash);
        
        
        const signature = await web3.eth.personal.sign(hash, cuenta);
        //const signature = web3.utils.soliditySha3("\x19Ethereum Signed Message:\n32", hash);
        console.log('ESTA ES LA FIRMA : '+signature);
        
        const resultF = await app.REGISTRO.activateAccount(nonce,cuenta,signature,{from:app.account});
        console.log(resultF);

        alert(resultF);

        /*var nonce2 = Math.floor(Math.random()*1000000001)
        console.log('numero ramdon2: '+nonce2)

        console.log('cuenta: '+cuenta)

        var hash2 = "0x" + web3.utils.sha3(
            ["uint256", "address", "address"],
            [nonce2, cuenta, cuenta]
          ).toString("hex");

        
        
        const signature2 = await web3.eth.personal.sign(hash2, cuenta);
        console.log(signature2)

        const resultado = await app.firma.isActive(nonce2,cuenta,signature2,{from:app.account});
        console.log(resultado)*/
    },

    consulta : async(idRegistro) => {

        //const cuentasss = app.account;

        const resultF = await app.REGISTRO.stateAccount(idRegistro,{from:app.account});
        console.log(resultF);
        alert(resultF);

    },
    /*createRegistro : async (code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas) => {

        const cuenta = app.account;
        console.log('cuenta: '+cuenta)
        
        const resultF = await app.REGISTRO.guardar(code,HasCachedAcl,{from:app.account})
        //const resultF = await app.registrosAbox.createRegistro(code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas,{from:app.account});
        console.log(resultF);

    },*/
    buscarRegristroPorId : async (idRegister) => {

        const cuenta = app.account;
        
        console.log('cuenta: '+cuenta);

        const resultF = await app.REGISTRO.buscar(idRegister);
        //const resultF = await app.registrosAbox.buscarRegristroPorId(idRegister,{from:app.account});
        console.log(resultF);



        //const result2 = await app.registrosAbox.buscarRegristroPorId(idRegistro)
        //console.log(result2)
        //console.log(result2.code,result2.HasCachedAcl,result2.idRegistro,result2.IsRemoved,result2.Name,result2.Reference,result2.Schemas)
        //const x = result2.code + result2.HasCachedAcl + result2.idRegistro + result2.IsRemoved + result2.Name + result2.Reference + result2.Schemas
        //document.getElementById('busqueda').innerText = x
    },
    buscarPorNombre : async (idRegistro) => {
        const result3 = await app.registrosAbox.buscarPorNombre(idRegistro)
        console.log(result3)
        document.getElementById('busqueda').innerText = result3
    }

}

app.init()