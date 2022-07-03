var contractAbi = [
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "initialValue",
                "type": "string"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [],
        "name": "value",
        "outputs": [
            {
                "internalType": "string",
                "name": "",
                "type": "string"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "newValue",
                "type": "string"
            }
        ],
        "name": "changeValue",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

async function setValue() {

    // Accessing the HTML Elements
    const ProcessIndicator = document.getElementById('ProcessIndicator')
    const NewValue = document.getElementById('NewValue')
    const Value = document.getElementById('Value')
    Value.innerHTML = "";
    ProcessIndicator.innerHTML = "Process Started. You will be notified After process is done."

    // The deployed contract's address
    const contractAddress = "0xc11AE1393Fc2a0681F84910233153967A6B4cB92";
    // Your account address from which the transaction will be sent 
    const accountAddress = "...Add your account address...";
    // The private key of the above account address
    const privateKey = new ethereumjs.Buffer.Buffer("...Add your private key...", 'hex');

    // Using Infura API to access the node  
    const web3 = new Web3("https://rinkeby.infura.io/v3/6d17d1d302fd468a9ccc16233e5ff1b8");

    // Setting the default account address 
    web3.eth.defaultAccount = accountAddress;

    // Creating the contract variable with the contract ABI and the deployed contract address
    var myContract = new web3.eth.Contract(contractAbi, contractAddress);

    // Accessing the methods / functions and calling the changeValue() funtion with the NewValue from the HTML Text Field
    const query = await myContract.methods.changeValue(NewValue.value).encodeABI();

    // Finally making the transaction
    web3.eth.getTransactionCount(accountAddress, (err, txCount) => {
        // Building the transaction
        const txObject = {
            nonce: web3.utils.toHex(txCount),
            to: contractAddress,
            value: web3.utils.toHex(web3.utils.toWei('0', 'ether')),
            gasLimit: web3.utils.toHex(2100000),
            gasPrice: web3.utils.toHex(web3.utils.toWei('60', 'gwei')),
            data: query
        }
        // Signing the transaction
        const tx = new ethereumjs.Tx(txObject, { chain: 'rinkeby' });
        tx.sign(privateKey);

        const serializedTx = tx.serialize();
        const raw = '0x' + serializedTx.toString('hex');

        // Broadcasting the transaction
        const transaction = web3.eth.sendSignedTransaction(raw).then(tx => {
            console.log('Tx:', tx);
            ProcessIndicator.innerHTML = "Process Completed."
        })
            .catch(e => {
                console.error('Error broadcasting the transaction: ', e);
                alert('Error broadcasting the transaction: ' + e)
            });
    })
}

async function getValue() {

    // Accessing the HTML Elements
    const ProcessIndicator = document.getElementById('ProcessIndicator')
    ProcessIndicator.innerHTML = "Process Started. You will be notified After process is done."
    const Value = document.getElementById('Value')
    Value.innerHTML = "";

    // The deployed contract's address
    const contractAddress = "0xc11AE1393Fc2a0681F84910233153967A6B4cB92";
    // Your account address from which the transaction will be sent 
    const accountAddress = "...Add your account address...";

    // Using Infura API to access the node  
    const web3 = new Web3("https://rinkeby.infura.io/v3/6d17d1d302fd468a9ccc16233e5ff1b8");

    // Setting the default account address 
    web3.eth.defaultAccount = accountAddress;

    // Creating the contract variable with the contract ABI and the deployed contract address
    var myContract = new web3.eth.Contract(contractAbi, contractAddress);

    // Accessing the methods / functions and calling the value() funtion
    var query = await myContract.methods.value().call({
        from: accountAddress,
    });

    // Displaying the result using HTML Elements
    Value.innerHTML = query;
    ProcessIndicator.innerHTML = "Process Completed."
}
