# Swift PASETO [![Build Status](https://travis-ci.org/aidantwoods/swift-paseto.svg?branch=master)](https://travis-ci.org/aidantwoods/swift-paseto)

A Swift implementation of [PASETO](https://github.com/paragonie/paseto).

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
        .upToNextMajor(from: "1.0.0")
    )
]
```

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
Let's say we want to generate a new version 4 symmetric key:

```swift
let symmetricKey = Version4.SymmetricKey()
```

Okay, now let's create a token:
```swift
var token = Token(claims: [
    "data":    "this is a signed message"
])

// set the expiry to 5 minutes from now
token.expiration = Date() + 5 * 60
```

Now encrypt it:
```swift
guard let encrypted = try? token.encrypt(with: symmetricKey) else { /* respond to failure */ }
```

To decrypt a token we need to parse it, and setup any validation rules we care about

```swift
var parser = Parser<Version4.Local>()
guard let try? decryptedToken = parser.decrypt(encrypted, with: symmetricKey) else { /* respond to failure */ }
```

By default, Parser will be initialised with a notExpired check. If you set your own rules
in the constructor you can override this. If you just want to add new rules, you can use the
`addRule` method without removing this default rule.

Let's say we want to generate a new version 4 secret (private) key:
```swift
let secretKey = Version4.AsymmetricSecretKey()
```

Now, if we wish produce a token which can be verified by others, we can
do the following:

```swift
let publicKey = secretKey.publicKey // we need to save this so we can send it to others
guard let signed = try? token.sign(with: secretKey) else { /* respond to failure */ }
```

To verify a message `signed` with a public key, e.g. `1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2`

```swift
let pkHex = "1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2"
guard let publicKey = try? Version4.AsymmetricPublicKey(hex: pkHex) else { /* this will fail if key is invalid */ }

var parser = Parser<Version4.Public>()
guard let try? verifiedToken = parser.verify(signed, with: publicKey) else { /* respond to failure */ }
```

Lastly, let's suppose that we do not start
with any objects. How do we create messages
and keys from strings or data?

Let's use the example from Paseto's test vectors:

The Paseto token is as follows (as a string/data)
```
v4.public.eyJkYXRhIjoidGhpcyBpcyBhIHNpZ25lZCBtZXNzYWdlIiwiZXhwIjoiMjAyMi0wMS0wMVQwMDowMDowMCswMDowMCJ9v3Jt8mx_TdM2ceTGoqwrh4yDFn0XsHvvV_D0DtwQxVrJEBMl0F2caAdgnpKlt4p7xBnx1HcO-SPo8FPp214HDw.eyJraWQiOiJ6VmhNaVBCUDlmUmYyc25FY1Q3Z0ZUaW9lQTlDT2NOeTlEZmdMMVc2MGhhTiJ9
```

And the symmetric key, given in hex is:
```
1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2
```

To produce a token, use the following:

```swift
let rawToken = "v4.public.eyJkYXRhIjoidGhpcyBpcyBhIHNpZ25lZCBtZXNzYWdlIiwiZXhwIjoiMjAyMi0wMS0wMVQwMDowMDowMCswMDowMCJ9v3Jt8mx_TdM2ceTGoqwrh4yDFn0XsHvvV_D0DtwQxVrJEBMl0F2caAdgnpKlt4p7xBnx1HcO-SPo8FPp214HDw.eyJraWQiOiJ6VmhNaVBCUDlmUmYyc25FY1Q3Z0ZUaW9lQTlDT2NOeTlEZmdMMVc2MGhhTiJ9"

guard let key = try? Version4.AsymmetricPublicKey(
    hex: "1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2"
) else {
    /* respond to failure */
}

var parser = Parser<Version4.Public>(rules: []) // setting rules to empty to remove expiry check:
                                                // this is only necessary for demonstration purposes because this token has expired
guard let token = try? parser.verify(rawToken, with: key) else {
    /* respond to failure */
}

// the following will succeed
assert(token.claims == ["data": "this is a signed message", "exp": "2022-01-01T00:00:00+00:00"])
assert(token.footer == "{\"kid\":\"zVhMiPBP9fRf2snEcT7gFTioeA9COcNy9DfgL1W60haN\"}")
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

where `version` is either `.v1`, `.v2`, `.v3`, or `.v4`, and `purpose` is either `.Public` (a
signed message) or `.Local` (an encrypted message).

As `Version` and `Purpose` are enums, it is recommended that you use an
explicitly exhaustive (i.e. no default) switch-case construct to select
different code paths. Making this explicitly exhaustive ensures that if, say
additional versions are added then the Swift compiler will inform you when you
have not considered all possibilities.

If you attempt to create a message using a raw token which produces a header that
does not correspond to the message's type arguments then the initialiser will fail.

# Supported Paseto Versions
## Version 4
Version 4 is fully supported.

## Version 3
Version 3 is fully supported.

## Version 2
Version 2 is fully supported.

## Version 1 (partial)
Version 1 (the compatibility version) is (ironically) only partially supported
due to compatibility issues (Swift is a new language 🤷‍♂️).

Version 1 in the local mode (i.e. encrypted payloads using symmetric keys) is
fully supported.
Version 1 in the public mode (i.e. signed payloads using asymmetric keys) is
**not** currently supported.
