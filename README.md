# Swift PASETO [![Build Status](https://travis-ci.org/aidantwoods/swift-paseto.svg?branch=master)](https://travis-ci.org/aidantwoods/swift-paseto)

A Swift implementation of [PASETO](https://github.com/paragonie/paseto).

## ⚠️  WARNING: IMPLEMENTATION IS A PRE-RELEASE.

Paseto is everything you love about JOSE (JWT, JWE, JWS) without any of the
[many design deficits that plague the JOSE standards](https://paragonie.com/blog/2017/03/jwt-json-web-tokens-is-bad-standard-that-everyone-should-avoid).


# Contents
* [What is Paseto?](#what-is-paseto)
  * [Key Differences between Paseto and JWT](#key-differences-between-paseto-and-jwt)
* [Installation](#installation)
  * [Requirements](#requirements)
  * [Dependencies](#dependencies)
* [Overview of the Swift library](#overview-of-the-swift-library)
* [Supported Paseto Versions](#supported-paseto-versions)

# What is Paseto?

[Paseto](https://github.com/paragonie/paseto) (Platform-Agnostic SEcurity
TOkens) is a specification for secure stateless tokens.

## Key Differences between Paseto and JWT

Unlike JSON Web Tokens (JWT), which gives developers more than enough rope with
which to hang themselves, Paseto only allows secure operations. JWT gives you
"algorithm agility", Paseto gives you "versioned protocols". It's incredibly
unlikely that you'll be able to use Paseto in
[an insecure way](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries).

> **Caution:** Neither JWT nor Paseto were designed for
> [stateless session management](http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/).
> Paseto is suitable for tamper-proof cookies, but cannot prevent replay attacks
> by itself.

# Installation

Using [Swift Package Manager](https://swift.org/package-manager/), add the
following to your `Package.swift`.

```swift
dependencies: [
    .package(
        url: "https://github.com/aidantwoods/swift-paseto.git",
        .upToNextMajor(from: "0.2.0")
    )
]
```

## Requirements
* Swift 4.1 and above.

## Dependencies
The following are automatically resolved when using Swift Package Manager.

* [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)

  CryptoSwift provides the secret key cryptography implementations, which are
  used in Version 1 local Paseto tokens.

* [Swift-Sodium](https://github.com/jedisct1/swift-sodium)

  Swift-Sodium provides the public key cryptography implementations, which are
  used in Version 2 public Paseto tokens, and is deferred to for various tasks
  such as: constant-time comparisons, constant-time encoding, and random number
  generation.

* [Clibsodium](https://github.com/tiwoc/Clibsodium)

  *Clibsodium is required by Swift-Sodium.*

  Clibsodium is used directly to provide the secret key cryptography
  implementations, which are used in Version 2 local Paseto tokens. When
  Swift-Sodium bridges these from the C library, Swift-Sodium will be used
  instead.

# Overview of the Swift library
The Paseto Swift library is designed with the aim of using the Swift compiler to
catch as many usage errors as possible.

At some point, you the user will have to decide which key to use when using
Paseto. As soon as you do this you effectively lock in two things: (i) the
version of Paseto tokens that you may use, (ii) the type of payload you
either want to check or produce (i.e. encrypted if using local tokens,
or signed if using public tokens).

The Paseto Swift library passes this information via type arguments (generics)
so entire classes of misuse examples aren't possible (e.g. 
creating a version 2 key and accidentally attempting to produce a version 1
token, or trying to decrypt a signed token). In-fact, the functions that would
enable you to even attempt these examples just don't exist.

Okay, so what does all that look like?

When creating a key, simply append the key type name to the version.
Let's say we want to generate a new version 1 symmetric key:

```swift
import Paseto
let key = Version1.SymmetricKey()
```

But version 2 is recommended, so let's instead use that. Just change the `1` to
a `2` (`import Paseto` is assumed hereafter):
```swift
let symmetricKey = Version2.SymmetricKey()
```

Okay, now let's create a token:
```swift
let token = Token(claims: [
    "data":    "this is a signed message",
    "expires": "2019-01-01T00:00:00+00:00",
])
```

Now encrypt it:
```swift
guard let message = try? token.encrypt(with: symmetricKey) else { /* respond to failure */ }
```

Then to get the encrypted token as a string, simply:
```swift
let pasetoToken = message.asString
```

Or even as data:
```swift
let pasetoTokenData = message.asData
```

`message` is of type `Message<Version2.Local>`. This means that it has a
specialised `decrypt(with: Version2.SymmetricKey)` method, which can be used
to retrieve the original token (when given a key). i.e. we can do:

```swift
guard let try? decryptedToken = message.decrypt(with: symmetricKey) else { /* respond to failure */ }
```


Let's say we want to generate a new version 2 secret (private) key:

```swift
let secretKey = Version2.AsymmetricSecretKey()
```

Now, if we wish produce a token which can be verified by others, we can
do the following:

```swift
guard let signedMessage = try? token.sign(with: secretKey) else { /* respond to failure */ }
```

`signedMessage` is of type `Message<Version2.Public>`. This means that it has a
specialised `verify(with: Version2.AsymmetricPublicKey)` method, which can be
used to verify the contents and produce a verified token.

To do this we need to export the public key from our `secretKey`.

```swift
let publicKey = secretKey.publicKey
```

`publicKey` is of type `Version2.AsymmetricPublicKey`, so we may use:

```swift
guard let try? verifiedToken = signedMessage.verify(with: publicKey) else { /* respond to failure */ }
```

to reproduce the original token from the `signedMessage`.


Lastly, let's suppose that we do not start
with any objects. How do we create messages
and keys from strings or data?

Let's use the example from Paseto's readme:

The Paseto token is as follows (as a string/data)
```
v2.local.QAxIpVe-ECVNI1z4xQbm_qQYomyT3h8FtV8bxkz8pBJWkT8f7HtlOpbroPDEZUKop_vaglyp76CzYy375cHmKCW8e1CCkV0Lflu4GTDyXMqQdpZMM1E6OaoQW27gaRSvWBrR3IgbFIa0AkuUFw.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc2Vz
```

And the symmetric key, given in hex is:
```
707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f
```

To produce a token, use the following:

```swift
let rawToken = "v2.local.QAxIpVe-ECVNI1z4xQbm_qQYomyT3h8FtV8bxkz8pBJWkT8f7HtlOpbroPDEZUKop_vaglyp76CzYy375cHmKCW8e1CCkV0Lflu4GTDyXMqQdpZMM1E6OaoQW27gaRSvWBrR3IgbFIa0AkuUFw.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc2Vz"

guard let key = try? Version2.SymmetricKey(
    hex: "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
) else {
    /* respond to failure */
}

guard let message = try? Message<Version2.Local>(rawToken) else {
    /* respond to failure */
}

guard let token = try? message.decrypt(with: key) else {
    /* respond to failure */
}

// the following will succeed
assert(token.claims == ["data": "this is a signed message", "exp": "2039-01-01T00:00:00+00:00"])
assert(token.footer == "Paragon Initiative Enterprises")
```

Keys can also be created using url safe base64 (with no padding) using
`init(encoded: String)` or with the raw key material as data
by using `init(material: Data)`.

If you need to determine the type of a received raw token, you can use the
helper function `Util.header(of: String) -> Header?` to retrieve a `Header`
corresponding to the given token. This only checks that the given string
is of a valid format, and does not guarantee anything about the contents.

For example, using `rawToken` from above:
```swift
guard let header = Util.header(of: rawToken) else { /* this isn't a valid Paseto token */ }
```

A `Header` is of the following structure:
```swift
struct Header {
    let version: Version
    let purpose: Purpose
}
```

where `version` is either `.v1` or `.v2`, and `purpose` is either `.Public` (a
signed message) or `.Local` (an encrypted message).

As `Version` and `Purpose` are enums, it is recommended that you use an
explicitly exhaustive (i.e. no default) switch-case construct to select
different code paths. Making this explicitly exhaustive ensures that if, say
additional versions are added then the Swift compiler will inform you when you
have not considered all possibilities.

If you attempt to create a message using a raw token which produces a header that
does not correspond to the message's type arguments then the initialiser will fail.

# Supported Paseto Versions
## Version 2
Version 2 (the recommended version by the specification) is fully supported.

## Version 1 (partial)
Version 1 (the compatibility version) is (ironically) only partially supported
due to compatibility issues (Swift is a new language 🤷‍♂️).

Version 1 in the local mode (i.e. encrypted payloads using symmetric keys) is
fully supported.
Version 1 in the public mode (i.e. signed payloads using asymmetric keys) is
**not** currently supported. You should not attempt to create signed messages or
asymmetric keys with `Version1` as a type argument, this will result in a fatal
error or exceptions being thrown.
