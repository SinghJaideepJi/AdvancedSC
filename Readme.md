# Crowd Funding Smart Contract

## Contract address on Ropsten Test Network
Contract address - 0x6a2c115fb8e060c99139f3d1aef9b364bc55c380

Transaction on Ropsten Testnet - https://ropsten.etherscan.io/tx/0x3e0b005ba86216b6d401d167e8571f3d72132b1c0839644b94946a0d82081c21

This contract utilizes one of the scalability technology in blockchain and also known as the layer 2 solution such as the State Channel. This also uses the built-in Message Verification function is solidity.

## Use Case

- The owner of the smart contract can propose an idea and deploy the smart contract asking for funds.

- Before deploying the maximum number of contributers can be defined(Currently set at 3 for testing purpose)

- Once the number of contributer limit is reached the funds are locked.

- When progress on project has been made then the Owner can ask the contributers to pay the developers. Only 10% of the original contribution is dispered to the developers per voting, hence the developers are paid in 10 installments this motivates them to keep progressing on the project.

- If the conributers are not happy with the progress of the project they can demand their money back. If they get 2/3rd majority the remaining balance in the can be claimed by the contributors on proportion of their initial contribution.

- If the contributors are happy with the progress of the project they can vote to pay the developers. If 2/3rd majority is happy with the progress the money is automatically transferred to the developers.

This mechanism ensures that the developers are kept motivated to progress on the project otherise they cannot claim their rewards and the contributors can get back their money.

## Functions Description

| Name  | Description | Parameters  |   Return
| ------------- | ------------- | ------------- | ------------- |
| fund  | payable function that accepts ether as funds if deposit is allowed. | N/A | N/A
| withdrawFunds  | withdraw funds if the Withdrawl is allowed | N/A | N/A
| happyWithProgress  | Vote on the progress of the Project if Voting Open | _vote (bool) , messageHash (bytes32), flatSignature (bytes) | N/A
| cleanupVotes | private function cleans up the votes and locks the voting for the next round. | N/A | N/A
| askForMoney | Owner can ask for release of money to pay for development based on the progress of the project. | N/A | N/A
| payTheDevs | private function transfers funds to the Owner to pay for development. | N/A | N/A# AdvancedSC
