use starknet::account;

// @title SRC-6 Standard Account
#[starknet::iterface]
trait ISRC6 {
	// @notice Execute a transaction through the account
	// @param calls The list of calls to execute
	// @return The list of each call's serialized return value
	fn __execute__(calls: Array<account::Call>) -> Array<Span<felt252>>;

	// @notice Assert whether the transaction is valid to be executed
	// @param calls The list of calls to execute
	// @return The string 'VALID' represented as a felt when is valid
	fn __validate__(calls: Array<account::Call>);

	// @notice Assert whether a given signature for a given hash is valid
	// @param hash The hash of the data
	// @param signature The signature to be validated
	// @return The string 'VALID' represented as a felt when is valid
	fn is_valid_signature(hash: felt252, signature: Array<felt252>) -> felt252;
}

// @title SRC-5 Iterface detection
#[starknet::iterface]
trait ISRC5 {
	// @notice Query if a contract implements an interface
	// @param interface_id The interface identifier, as specified in SRC-5
	// @return `true` if the contract implements `interface_id`, `false` otherwise
	fn supports_interface(interface_id: felt252) -> bool;
}

#[starknet::contract]
mod Multisign {
	#[storage]
	struct Storage {
	}
}
