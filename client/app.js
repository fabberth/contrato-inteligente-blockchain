
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
           web3 = new Web3(window.web3.currentProvider)
        }
        else{
            console.log('instalar metamask')
        }
    },
    loadAccount: async () =>{
        const cuentas = await window.ethereum.request({method: 'eth_requestAccounts'});
        app.account = cuentas[0]
    },

    loadContracts: async () => {
        const  res = await fetch("registrosAbox.json")
        const registrosAboxJSON = await res.json()

        app.contracts.registrosAbox = TruffleContract(registrosAboxJSON)

        app.contracts.registrosAbox.setProvider(app.web3Provider)

        app.registrosAbox = await app.contracts.registrosAbox.deployed()

    },
    render: ()=> {
        console.log(app.account)
        document.getElementById('mostar').innerText = app.account
    },
    createRegistro : async (code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas) => {
        //console.log(code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas)
        const result = await app.registrosAbox.createRegistro(code,HasCachedAcl,idRegistro,IsRemoved,Name,Reference,Schemas,{from:app.account})
        console.log(result)
    },
    buscarRegristroPorId : async (idRegistro) => {
        const result2 = await app.registrosAbox.buscarRegristroPorId(idRegistro)
        console.log(result2.code,result2.HasCachedAcl,result2.idRegistro,result2.IsRemoved,result2.Name,result2.Reference,result2.Schemas)
        const x = result2.code + result2.HasCachedAcl + result2.idRegistro + result2.IsRemoved + result2.Name + result2.Reference + result2.Schemas
        document.getElementById('busqueda').innerText = x
    },
    buscarPorNombre : async (idRegistro) => {
        const result3 = await app.registrosAbox.buscarPorNombre(idRegistro)
        console.log(result3)
        document.getElementById('busqueda').innerText = result3
    }

}

app.init()