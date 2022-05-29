

const initialize = () => {

    const connectButton = document.getElementById('connectButton');
    const updateChangesButton = document.getElementById('updateChangesButton');
    const sendEthButton = document.getElementById('sendEthButton');
    const requestPermitionButton = document.getElementById('requestPermitionButton');
    const displayAccountAddress = document.getElementById('displayAccountAddress');
    const displayChainId = document.getElementById('displayChainId');
    const displayNetworkId = document.getElementById('displayNetworkId');
    const displayChangesMade = document.getElementById('displayChangesMade');


    let accounts = [];


    const isMetaMaskInstalled = () => {
        const { ethereum } = window;
        return Boolean(ethereum && ethereum.isMetaMask);
    };

    const onClickConnect = async () => {
        try {
            await ethereum.request({ method: 'eth_requestAccounts' });
            updateAll();
            sendEthButton.disabled = false;
            requestPermitionButton.disabled = false;
            connectButton.innerText = 'Log Out';
            connectButton.onclick = onLogOut;
        } catch (error) {
            console.error(error);
        }
    };

    async function onLogOut() {
        displayAccountAddress.innerText = '';
        displayChainId.innerText = '';
        displayNetworkId.innerText = '';
        displayChangesMade.innerText = '';
    }

    const onClickInstall = () => {
        connectButton.innerText = 'Onboarding in progress';
        connectButton.disabled = true;
        window.open("https://metamask.io/");
    };

    const MetaMaskClientCheck = () => {
        if (isMetaMaskInstalled()) {
            connectButton.innerText = 'Connect';
            connectButton.onclick = onClickConnect;
            connectButton.disabled = false;
        } else {
            connectButton.innerText = 'Click here to install MetaMask!';
            connectButton.onclick = onClickInstall;
            connectButton.disabled = false;
        }
    };

    async function updateAll() {
        updateAccounts();
        updateChain();
        updateNetwork();
        displayChangesMade.innerHTML = '';
    }

    async function updateAccounts() {
        accounts = await ethereum.request({ method: 'eth_accounts' });
        displayAccountAddress.innerHTML = accounts[0] || 'Not able to get accounts';
    }

    async function updateChain() {
        const chainId = await ethereum.request({ method: 'eth_chainId' });
        displayChainId.innerHTML = chainId || 'Not able to get chain ID';
    }

    async function updateNetwork() {
        const networkId = await ethereum.request({ method: 'net_version' });
        displayNetworkId.innerHTML = networkId || 'Not able to get network ID';
    }

    async function changesMade() {
        displayChangesMade.innerHTML = 'Changes in Account / Network has been made by MetaMask.';
        updateChangesButton.disabled = false;
        updateChangesButton.onclick = updateAll;
    }

    sendEthButton.addEventListener('click', () => {
        ethereum
            .request({
                method: 'eth_sendTransaction',
                params: [
                    {
                        from: accounts[0],
                        to: '0x180D7b4514CF8ad2e9d826734b3472B0A4a8266b',
                        value: '0x00',
                        gasPrice: '0x09184e72a000',
                        gas: '0x2710',
                    },
                ],
            })
            .then((txHash) => console.log(txHash))
            .catch((error) => console.error);
    });

    requestPermitionButton.addEventListener('click', async () => {
        try {
            const permissionsArray = await ethereum.request({
                method: 'wallet_requestPermissions',
                params: [{ eth_accounts: {} }],
            })
        } catch (error) {
            console.error(error);
        }
    });


    function init() {
        connectButton.disabled = false;
        updateChangesButton.disabled = true;
        sendEthButton.disabled = true;
        requestPermitionButton.disabled = true;
    }

    init();
    MetaMaskClientCheck();
    ethereum.on('accountsChanged', changesMade);
    ethereum.on('chainChanged', changesMade);
    ethereum.on('networkChanged', changesMade);
};

window.addEventListener('DOMContentLoaded', initialize);

