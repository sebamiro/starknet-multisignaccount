use starknet::account;

// @title SRC-6 Standard Account
#[starknet::interface]
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
		self: @T,
		hash: felt252,
		signature: Array<felt252>
	) -> felt252;
}

// @title SRC-5 Iterface detection
#[starknet::interface]
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
	use starknet::account;

	const MAX_SIGNERS_COUNT: usize = 32;

	#[storage]
	struct Storage {
		signers: LegacyMap<felt252, felt252>,
		threshold: usize,
		outside_nonce: LegacyMap<felt252, felt252>
	}

	#[constructor]
	fn constructor(
		ref self: ContractState,
		threshold: usize,
		signers: Array<felt252>) {
		assert_threshold(threshold, signers.len());

		self.add_signers(signers.span(), 0);
		self.threshold.write(threshold);
	}

	#[external(v0)]
	impl SRC6 of ISRC6<ContractState> {
		fn __execute__(
			ref self: ContractState,
			calls: Array<account::Call>
		) -> Array<Span<felt252>> {
			ArrayTrait::new()
		}

		fn __validate__(
			self: @ContractState,
			calls: Array<account::Call>
		) -> felt252 {
			0
		}

		fn is_valid_signature(
			self: @ContractState,
			hash: felt252,
			signature: Array<felt252>
		) -> felt252 {
			0
		}
	}

	#[external(v0)]
	impl SRC5 of ISRC5<ContractState> {
		fn supports_interface(
			self: @ContractState,
			interface_id: felt252
		) -> bool {
			false
		}
	}

	#[generate_trait]
	impl Private of PrivateTrait {
		fn add_signers(
			ref self: ContractState,
			mut signers: Span<felt252>,
			last: felt252
		) {
			match signers.pop_front() {
				Option::Some(signer_ref) => {
					let signer = *signer_ref;
					assert(signer != 0, 'signer/zero-signer');
					assert(!self.is_signer_using_last(signer, last),
						'signer/is-already-signer');
					self.signers.write(last, signer);
					self.add_signers(signers, signer);
				},
				Option::None => ()
			}
		}

		fn is_signer_using_last(
			self: @ContractState,
			signer: felt252,
			last: felt252
		) -> bool {
			if signer == 0 {
				return false;
			}

			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			last == signer
		}
	}

	fn assert_threshold(threshold: usize, signers_len: usize) {
		assert(threshold != 0, 'threshold/is-zero');
		assert(signers_len != 0, 'signers_len/is-zero');
		assert(signers_len <= MAX_SIGNERS_COUNT,
				'signers_len/too-high');
		assert(threshold <= signers_len, 'threshold/too-high');
	}
}

#[starknet::interface]
trait TestMultisign<T> {
	fn __execute__(ref self: T, calls: Array<account::Call>) -> Array<Span<felt252>>;
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;
	fn is_valid_signature( self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}
