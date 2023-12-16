use starknet::account;

// @title SRC-6 Standard Account
#[starknet::iterface]
trait ISRC6<T> {
	// @notice Execute a transaction through the account
	// @param calls The list of calls to execute
	// @return The list of each call's serialized return value
	fn __execute__(
		ref self: T,
		calls: Array<account::Call>
	) -> Array<Span<felt252>>;

	// @notice Assert whether the transaction is valid to be executed
	// @param calls The list of calls to execute
	// @return The string 'VALID' represented as a felt when is valid
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;

	// @notice Assert whether a given signature for a given hash is valid
	// @param hash The hash of the data
	// @param signature The signature to be validated
	// @return The string 'VALID' represented as a felt when is valid
	fn is_valid_signature(
		self @T,
		hash: felt252,
		signature: Array<felt252>
	) -> felt252;
}

// @title SRC-5 Iterface detection
#[starknet::iterface]
trait ISRC5<T> {
	// @notice Query if a contract implements an interface
	// @param interface_id The interface identifier, as specified in SRC-5
	// @return `true` if the contract implements `interface_id`, `false` otherwise
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

// @title Multisign Account
#[starknet::contract]
mod Multisign {
	use super::ISRC6;
	use super::ISRC5;

	#[storage]
	struct Storage {
		signers: LegacyMap<felt252, felt252>,
		threshold: usize,
		outside_nonce: LegacyMap<felt252, felt252>
	}

	#[contructor]
	fn contructor(
		ref self: ContractState,
		threshold: usize,
		signers: Array<felt252>) {}

	#[external(v0)]
	impl SRC6 of ISRC6 {
		fn __execute__(
			ref self: ContractState,
			calls: Array<account::Call>
		) -> Array<Span<felt252>> {}

		fn __validate__(
			self: @ContractState,
			calls: Array<account::Call>
		) -> felt252 {}

		fn is_valid_signature(
			self @ContractState,
			hash: felt252,
			signature: Array<felt252>
		) -> felt252;
	}

	#[external(v0)]
	impl SRC5 of ISRC5 {
		fn supports_interface(
			self: @ContractState,
			interface_id: felt252
		) -> bool {}
	}
}
