## How to run  (Integration)

### 1. In `./nodes/node2` folder :
```bash
chmod 755 run.sh && ./run.sh
```
The RPC is `http://0.0.0.0:8565/`


### 1. In `./contracts` folder :

```bash
cp env.example .env # fill in with private keys
```
```bash
yarn install
```
```bash
yarn compile
```
```bash
yarn deploy --network l2
```

this will :
- this will deploy a contract for beautifood
- this will give assets to account 2
- this will submit a menu for store with address equal to account 1
- this will mint tokens for account 2
- this will make an order from account 2 to account 1 (store)

details for accounts with private keys : will send in DM