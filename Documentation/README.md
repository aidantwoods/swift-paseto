# Contents
* [General Paseto Overview](#general-paseto-overview)
* [General Paseto Usage](#general-paseto-usage)
* [The Paseto Message](#the-paseto-message)
  * [Creating a Paseto Message](#creating-a-paseto-message)
  * [⚠️ Accessing the Footer Prior to Decryption or Verification](#accessing-the-footer-prior-to-decryption-or-verification)
  * [Transferable Formats](#transferable-formats)
* [Paseto Keys](#paseto-keys)
  * [General Keys](#general-keys)
    * [General Key Methods](#general-key-methods)
        * [Constructing a General Key from Key Material](#constructing-a-general-key-from-key-material)
        * [Exporting a General Key from Key Material](#exporting-a-general-key-from-key-material)
    * [Additional General Key Methods](#additional-general-key-methods)
  * [Symmetric Keys](#symmetric-keys)
    * [Generating a new Symmetric Key](#generating-a-new-symmetric-key)
    * [Exporting a Symmetric Key for Storage](#exporting-a-symmetric-key-for-storage)
  * [Asymmetric Secret Keys](#asymmetric-secret-keys)
    * [Generating a new Asymmetric Secret Key / Keypair](#generating-a-new-asymmetric-secret-key-keypair)
    * [Exporting an Asymmetric Secret Key for Storage](#exporting-an-asymmetric-secret-key-for-storage)
  * [Asymmetric Public Keys](#asymmetric-public-keys)
    * [Obtaining a Public Key from a Secret Key](#obtaining-a-public-key-from-a-secret-key)
    * [Obtaining a Public Key from Key Material](#obtaining-a-public-key-from-key-material)
    * [Generating a new Public Key](#generating-a-new-public-key)
    * [Exporting an Asymmetric Public Key for Storage](#exporting-an-asymmetric-public-key-for-storage)
* [Wrapping up](#wrapping-up)
  * [Example](#example)


# General Paseto Overview
Each version of Paseto provides a ciphersuite with a selection of
implementaions for: authenticated encryption, authenticated decryption,
signatures, and verification.

If you need to keep data secret, you are looking for the `local` part of API,
which performs encryption and decryption.

If you **do not** want data to be encrypted, you are looking for the `public`
part of the API, which performs signing and verification of non-encrypted data.

All modes verify the message integrity (i.e. there does not exist an
unauthenticated mode of encryption).

In all modes, you may optionally provide an authentication tag
("footer", henceforth). **The footer is never encrypted**, but it is **always**
authenticated. You may wish to use this to provide additional information
that does not itself need to be kept secret. Because this footer is always
authenticated it cannot be modified in transit without detection.

# General Paseto Usage
> The following is subject to change while the Paseto specification is
> in draft.

Forewarning that the following goes into vigorous detail. You should treat
this all as required reading, however actual usage is very simple, see
[wrapping up](#example) for a full usage example.

In the Swift library, each version of Paseto will have the following methods:
```swift
encrypt(_:with:footer:)
decrypt(_:with:)
sign(_:with:footer:)
verify(_:with:)
```

The first argument to all of these will correspond to either the plaintext
that needs encrypting or signing, or a recieved Paseto message that needs
decrypting or verifying.
The second argument `with:` will be a key which is *appropriate* for the given
task.

> The *appropriate* key for any given encrypt, decrypt, sign, or verify
> operation for any version is a type safety checked requirement. Providing a
> key which is not *appropriate* is therefore a compile error by design.

In particular, each version will implement the following protocol:

```swift
protocol Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>, footer: Data
    ) throws -> Blob<Encrypted<Self>>

    static func decrypt(
        _ encrypted: Blob<Encrypted<Self>>, with key: SymmetricKey<Self>
    ) throws -> Data

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>, footer: Data
    ) throws -> Blob<Signed<Self>>

    static func verify(
        _ signedMessage: Blob<Signed<Self>>, with key: AsymmetricPublicKey<Self>
    ) throws -> Data
}
```

All methods are (at worst) throwing, but individual implementations may
provide non-throwing versions of some of these functions as appropriate.

In addition to these methods, there are various convenience overloads
implemented in protocol extensions in terms of these four base methods
(thus any specific implementation will have these available).

In particular, and for example: overloads exist that allow omission of the
footer, as well as overloads that will take a `String` in place of `Data`. If a
`String` is provided, `UTF-8` encoding will be used to represent the `String`
as bytes when transforming to `Data`.

# The Paseto Message
The Paseto message is what will be produced by the encrypting and signing
methods, and is what should be given to the decrypting and verification methods.

In the Swift library, a Paseto message is implemented as `Blob<P: Payload>`,
where the generic argument is a type of `Payload`.
> Before explaining the detail, it helps to see an example of this written out
> explicitly. For example, `Blob<Signed<Version2>>` is a Paseto message which
> has been signed using version 2 of Paseto's ciphersuite selection.

The only valid `Payload` types are: `Encrypted<V: Implementation>`, and
`Signed<V: Implementation>`, where `V` is an `Implementation` (the protocol
is defined above).
For example, the following are valid `Payload` types: `Encrypted<Version1>`,
`Signed<Version2>`.

The only public method of `Blob<P: Payload>` is as follows:

```swift
struct Blob<P: Payload> {
    public init? (_ string: String)
}
```

*there are computed properties which are accessible too, these will be
covered later*.

## Creating a Paseto Message

Paseto messages can be constructed by either encrypting or signing data,
in which case a Paseto message (as a `Blob`) will be the output format.

A Paseto messages can also be constructed from a recieved message:

`init?(_:)` is a failible initializer, and is where you should provide
a received Paseto message in its `String` representation.

For example, if you expect `message` to store a version 2 signed Paseto message
as a `String`, use the following:

```swift
guard let blob = Blob<Signed<Version2>>(message) else { ... }
```

If this initializer fails, there are two possible causes (both may occur
simultaneously):
1. The Paseto message is invalid. There is no way to correct this
  in general. It is recommended that you discard the invalid message. You need
  to decide what is best to do here in response.
2. The expected payload type (i.e. the `P: Payload` provided in type parameters
  does not match what the message claims to be in its header).
  If this occurs you should consider whether or not it is approprate to allow
  the message to choose what to do here.
  If you decide to allow the message header to decide what action to take, you
  should ensure you make appropriate considerations when picking a key to verify
  the message with.

  The following will allow you to select different code paths based on the
  message type specified in the header:
  ```swift
  guard let header = Util.header(of: message) else { /* message isn't valid, see 1. */ }

  switch (header.version, header.purpose) {
  case (.v1, .Public): /* this is not currently supported */
  case (.v1, .Local):
      guard let blob = Blob<Encryped<Version1>>(message) else {
          /* message isn't valid, see 1. */
      }
      ...
  case (.v2, .Public):
      guard let blob = Blob<Signed<Version2>>(message) else {
          /* message isn't valid, see 1. */
      }
      ...
  case (.v2, .Local):
      guard let blob = Blob<Encryped<Version2>>(message)else {
          /* message isn't valid, see 1. */
      }
      ...
  }
  ```

  Note that although the message format is checked for validity when using
  `Util.header(of:)`, it is still possible that the payload within the message
  does not conform to the specific formatting requirements determined by the
  version and purpose combination. It is therefore important that the provided
  guard statements are used within the switch-case construct. Force unwrapping
  here instead would allow the possibility of unhandled errors at runtime.


## Accessing the Footer Prior to Decryption or Verification

> ⚠️  **WARNING: Do not trust a footer value until you have successfully
> decrypted or verified the blob.**
> 
> This value is made available pre-verification/decryption because it may
> be useful for, for example placing a key id in the footer. This could be used
> so that the blob itself can indicate which of your trusted keys it requires
> for decryption/verification.
> 
> **Be aware that early extraction of the footer is a completely
> unauthenticated claim until the authenticity of the blob has been proved**
> (by either success of decryption or verification with a trusted key).

To access the footer of an already constructed Blob `blob`, use

```swift
let blobFooter = blob.footer
```

## Transferable Formats

If you have produced a `Blob` you will need to convert it to a `String` or
`Data` in order to send or store it anywhere. To do this given a Blob `blob`,
use either one of (as required):

```swift
let pasetoString = blob.asString
let pasetoData = blob.asData
```


# Paseto Keys

## General Keys
Paseto has three distinct types of keys (up to version implementations).
All versions will have the following types of keys:
`AsymmetricPublicKey<V: Implementation>`,
`AsymmetricSecretKey<V: Implementation>`,
`SymmetricKey<V: Implementation>`.

If you are using the local portion of the API, both encryption and decryption
require the same key, which should be of type:
`SymmetricKey<V: Implementation>`.
Where `V` specifies the implementation you wish to use.
For example: `SymmetricKey<Version2>` refers to a version 2 symmetric key.

Any of the above keys will implement the `Key` protocol, which means you can
expect all keys to have the following public API:

### General Key Methods

```swift
protocol Key {
    associatedtype VersionType: Implementation

    var material: Data { get }
    init (material: Data) throws
}
```

For any of the above keys, `VersionType` will hold the type parameter `V`.

#### Constructing a General Key from Key Material

`init (material:)` should be provided with the raw key material in bytes as
`Data`. This method will throw if the key is not valid for the particular
implementation.

#### Exporting a General Key from Key Material

`var material: Data` will return the material provided to the key upon
initialization.

You should ensure that this key is stored safely if it is not intended to
be shared with third parties!


### Additional General Key Methods

Additionally, every key will inherit the following convenience API via
a protocol extension:


```swift
extension Key {
    var encode: String
    init (encoded: String) throws
    init (hex: String) throws
    static var version: Version
}
```

`var encode: String` will return the key material as a String, encoded
using URL-safe base64 with no padding.

`init (encoded:)` will create a key by obtaining the raw material by decoding
the above stated encoded format.

`init (hex:)` will create a key by obtaining the raw material by intepreting
the given string as hexadecimal encoded bytes with no separators.

`static var version: Version` will provide the enum state representation of
`VersionType`.


## Symmetric Keys

If you are using the `local` part of the API, you will need to use the same
symmetric key (`SymmetricKey<V: Implementation>`) for both encryption and
decryption.

### Generating a new Symmetric Key

In addition to the above methods common to all keys,
`SymmetricKey<V: Implementation>` will have a default initializer `init ()`.
Calling this will generate a new key from random data according to the specific
requirements of the particular implementation.

For example,

```swift
let key = SymmetricKey<Version2>()
```

will generate a new symmetric key for use with Version 2 of Paseto's
ciphersuite.

Because this is a new key, it is important that you save the underlying key
material so that you can later decrypt any messages you encrypt this key with.

### Exporting a Symmetric Key for Storage

You should ensure that this key is stored safely! If the exported material
of this key becomes known to a third party you must discontinue use of the key
and cease to trust the authenticity of messages encrypted with this key.

You may export the key material to the encoded format using the following:

```swift
let verySensitiveKeyMaterial = key.encode
```

## Asymmetric Secret Keys

If you are using the `public` part of the API, you will need to use a pair of
keys (a keypair):
An asymmetric secret key (`AsymmetricSecretKey<V: Implementation>`) for signing
(secret key, henceforth).
And an asymmetric public key (`AsymmetricPublicKey<V: Implementation>`) for
verifying said signatures (public key, henceforth).

We will cover asymmetric secret keys first because their implementations contain
data required to reconstruct the keypair. A public key can always be exported
from a secret key, however a secret key can never be exported from a public key.

### Generating a new Asymmetric Secret Key / Keypair

In addition to the methods common to all keys,
`AsymmetricSecretKey<V: Implementation>` will have a default initializer
`init ()`.
Calling this will generate a new secret key from random data according to the
specific requirements of the particular implementation.

For example,

```swift
let secretKey = AsymmetricSecretKey<Version2>()
```

will generate a new secret key for use with Version 2 of Paseto's
ciphersuite.

> Note that only version 2 of the is supported at this time for signing
> and verification.

Because this is a new key, it is important that you save the underlying key
material so that you can continue to sign messages that can be verified by the
corresponding public key.

### Exporting an Asymmetric Secret Key for Storage

You should also ensure that this key is stored safely! If the exported material
of this key becomes known to a third party you must discontinue use of the key
and cease to trust the authenticity of messages signed with this key.

You may export the secret key material to the encoded format using the
following:

```swift
let verySensitiveSecretKeyMaterial = secretKey.encode
```

## Asymmetric Public Keys
If you are using the `public` part of the API, you will need to use
a public key (`AsymmetricPublicKey<V: Implementation>`) to verify messages.

There are two ways to obtain a public key:

### Obtaining a Public Key from a Secret Key

If you have a secret key, you can export the corresponding public key,
which will produce a key of the same version.
Given a secret key `secretKey`, use the following to do this:
```swift
let publicKey = secretKey.publicKey
```

### Obtaining a Public Key from Key Material

If you have public key material, use one of the initializers specified
in the `Key` protocol to construct a `AsymmetricPublicKey<V: Implementation>`
from this material.

For example to construct a public key from raw material `material` intended
for Version 2 of Paseto, use the following:
```swift
guard let publicKey = try? AsymmetricPublicKey<Version2>(material) else {
    /* bad material given */
}
```

### Generating a new Public Key

Public keys cannot be generated without a corresponding secret key. If you have
neither you should generate a new secret key and then export its corresponding
public key.

### Exporting an Asymmetric Public Key for Storage

If you wish to export your public key to share, so that a recipient of one
of your signed messages may verify its integrity, use the following:

```swift
let sharablePublicKeyMaterial = publicKey.encode
```

Unlike when dealing with the other types of keys that must not be shared, this
is a perfectly safe operation to share the result of.

# Wrapping up
You are now familiar with all the details you need to construct all the types
that will be used to transition between data and Paseto messages. Hooray! 🎉

As you now know, `Version2` implements `Implementation`.
And so thus implements the following method:

```swift
static func encrypt(
    _ message: Data,
    with key: SymmetricKey<Version2>,
    footer: Data
) throws -> Blob<Encrypted<Version2>>
```

Version 2 in-fact implements a non-throwing version of this method, and as
previously discussed, an overload is available via the `Implementation` protocol
that will allow `footer` to be omitted because it is optional.

## Example
The following will generate a new symmetric key, encrypt a message with it,
convert it to a `String` for sending, and store the key used in an exported
format:

```swift
let key = SymmetricKey<Version2>()
let message = Version2.encrypt("Hello world!", with: key)
let pasetoString = message.asString
let verySensitiveKeyMaterial = key.encode
```