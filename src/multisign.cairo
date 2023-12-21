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
			if self.is_valid_signature_span(hash, signature.span()) {
				starknet::VALIDATED
			} else {
				0
			}
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

		fn is_valid_signature_span(
			self: @ContractState,
			hash: felt252,
			signature: Span<felt252>
		) -> bool {
			let threshold = self.threshold.read();
			assert(threshold != 0, 'Uninitialized');
			let mut signatures = deserialize_signatures(signature)
				.expect('signature/invalid-len');
			assert(threshold == signatures.len(), 'signature/invalid-len');
			let mut last: u256 = 0;
			loop {
				match signatures.pop_front() {
					Option::Some(signature_ref) => {
						let signature = *signature_ref;
						let signer_uint = signature.signer.into();
						assert(signer_uint > last, 'signature/not-sorted');
						if !self.is_valid_signer_signature(
								hash,
								signature.signer,
								signature.signature_r,
								signature.signature_s,
							) {
							break false;
						}
						last = signer_uint;
					},
					Option::None => {
						break true;
					}
				}
			}
		}

		fn is_valid_signer_signature(
			self: @ContractState,
			hash: felt252,
			signer: felt252,
			signature_r: felt252,
			signature_s: felt252
		) -> bool {
			assert(self.is_signer(signer), 'signer/not-a-signer');
			ecdsa::check_ecdsa_signature(hash, signer, signature_r, signature_s)
		}

		fn is_signer(self: @ContractState, signer: felt252) -> bool {
			if signer == 0 {
				return false;
			}
			let next = self.signers.read(signer);
			if next != 0 {
				return true;
			}
			self.get_last() == signer
		}

		fn get_last(self: @ContractState) -> felt252 {
			let mut curr = self.signers.read(0);
			loop {
				let next = self.signers.read(curr);
				if next == 0 {
					break curr;
				}
				curr = next;
			}
		}
	}

	fn assert_threshold(threshold: usize, signers_len: usize) {
		assert(threshold != 0, 'threshold/is-zero');
		assert(signers_len != 0, 'signers_len/is-zero');
		assert(signers_len <= MAX_SIGNERS_COUNT,
				'signers_len/too-high');
		assert(threshold <= signers_len, 'threshold/too-high');
	}

	#[derive(Copy, Drop, Serde)]
	struct SignerSignature {
		signer: felt252,
		signature_r: felt252,
		signature_s: felt252
	}

	fn deserialize_signatures(
		mut serialized: Span<felt252>
	) -> Option<Span<SignerSignature>> {
		let mut signatures = ArrayTrait::new();
		loop {
			if serialized.len() == 0 {
				break Option::Some(signatures.span());
			}
			match Serde::deserialize(ref serialized) {
				Option::Some(s) => { signatures.append(s) },
				Option::None => { break Option::None; },
			}
		}
	}
}

#[starknet::interface]
trait TestMultisign<T> {
	fn __execute__(ref self: T, calls: Array<account::Call>) -> Array<Span<felt252>>;
	fn __validate__(self: @T, calls: Array<account::Call>) -> felt252;
	fn is_valid_signature( self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
	fn supports_interface(self: @T, interface_id: felt252) -> bool;
}
