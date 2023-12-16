use multisign::multisign::{ TestMultisignDispatcher, TestMultisignDispatcherTrait };
use snforge_std::{ declare, ContractClassTrait };

const signer_pubkey_1: felt252 =
	0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;

const signer_pubkey_2: felt252 =
	0x759ca09377679ecd535a81e83039658bf40959283187c654c5416f439403cf5;

const signer_pubkey_3: felt252 =
	0x411494b501a98abd8262b0da1351e17899a0c4ef23dd2f96fec5ba847310b20;

// @dev Declares a mutlisign account
// @param threshold Size of the threshold for the account
// @param signers Array of the signers for the account
// @returns The dispatcher of the contract_address of the account
//
fn deploy(
	threshold: usize,
	mut signers: Span<felt252>
) -> TestMultisignDispatcher {

	let contract = declare('Multisign');
	let mut calldata = ArrayTrait::new();
	calldata.append(threshold.into());
	calldata.append(signers.len().into());
	loop {
		match signers.pop_front() {
			Option::Some(signer) => {
				calldata.append(*signer)
			},
			Option::None => {
				break;
			}
		};
	};
	TestMultisignDispatcher {
		contract_address: contract.deploy(@calldata).unwrap()
	}
}
