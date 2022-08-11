import Onboard from 'bnc-onboard'

const ACTIVE_NETWORK_ID = 1
const INFURA_KEY = "6ff37f3b33474c90b115571657bad792"
const APP_URL = "https://tatertownNFT.com/"
const CONTACT_EMAIL = "contact@mandox.io"
const RPC_URL = "https://mainnet.infura.io/v3/6ff37f3b33474c90b115571657bad792"
const APP_NAME = "Tater Town Mint"

const wallets = [
  { walletName: "metamask" },
  {
    walletName: "walletConnect",
    infuraKey: INFURA_KEY
  },
  { walletName: "coinbase"},
  { walletName: "trust", rpcUrl: RPC_URL},

]

export const onboard = Onboard({
  //... other options
  dappId: 'cfc3e1e8-75ab-498e-9869-c4a3a68917ef',
  networkId: ACTIVE_NETWORK_ID,
  walletSelect: {
    wallets: wallets,
  },
});

export function initOnboard(subscriptions) {
  return Onboard({
    dappId: 'cfc3e1e8-75ab-498e-9869-c4a3a68917ef',
    networkId: ACTIVE_NETWORK_ID,
    subscriptions,
    walletSelect: {
      wallets: wallets,
    },
    walletCheck: [
      {checkName: 'derivationPath'},
      {checkName: 'connect'},
      {checkName: 'accounts'},
      {checkName: 'network'},
    ],
  });
}