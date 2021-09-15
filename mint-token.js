const Web3 = require('web3')
var Tx = require('ethereumjs-tx').Transaction;
const fs = require('fs');

const rpcURL = "" // required
const account = "" // required
const privateKey = Buffer.from('', 'hex') // required
const tokenId = 0 // required
const tokenData = "0x0"
const contractAddress = "" // required
const builtContract = JSON.parse(fs.readFileSync('./build/contracts/SaleErc1155.json', 'utf8'));

const web3 = new Web3(rpcURL)

const contract = new web3.eth.Contract(builtContract.abi, contractAddress)

web3.eth.getTransactionCount(account, (err, txCount) => {

    const txObject = {
      nonce:    web3.utils.toHex(txCount),
      gasLimit: web3.utils.toHex(8500000),
      gasPrice: web3.utils.toHex(web3.utils.toWei('20', 'gwei')),
      to: contractAddress,
      data: contract.methods.mint(account, tokenId, 1, tokenData).encodeABI()
    }
  
    const tx = new Tx(txObject)
    tx.sign(privateKey)
  
    const serializedTx = tx.serialize()
    const raw = '0x' + serializedTx.toString('hex')
  
    web3.eth.sendSignedTransaction(raw, (err, txHash) => {
      console.log('err:', err, 'txHash:', txHash)
    })
})
