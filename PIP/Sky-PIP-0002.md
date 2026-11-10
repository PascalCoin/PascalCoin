<pre>
  PIP: *reserved for PIP editor*
  Title: Sky-PIP-0002, Ask for PASA Server + Client + Captchas.
  Type: Protocol | Backend | Front-End | Informational | Process
  Impact: [Hard-Fork|Soft-Fork|None] - [Protcol | API | GUI | Mobile | Other]
  Author: Skybuck Flying <i>&lt;skybuck2000@hotmail.com&gt;</i>
  Comments-URI: *reserved for PIP editor*
  Status: Draft
  Created: 2022-01-13
</pre>

## Summary

Ask for PASA Server + Client component for PascalCoin
 
## Motivation

Currently the Ask for PASA functionality seems to be gone/disabled.

The PASA functionality was disabled because of mis-use/abuse of the Ask for PASA feature.

Aledgedly a script was used to collect a lot of free PASAs.

To prevent scripting it is necessary to fall back to a method that requires human interaction.

A captcha comes to mind. A captcha is a visual image containing letters, symbols, digits or even words or other objects
that must be recgonized by a human but is hard for a computer to recgonize.

## Specification

Users/Miners of PascalCoin should be able to offer their excessive PASAs to a PASA Server.

The PASA Server components runs on their machine.

The PASA Server component generates a Captcha whenever a PASA Client requests a free PASA.

The PASA Client randomly selects one of the available PASA Servers.

The PASA Server components "register/announce" themselfes on the PascalCoin network through propagation messages.

The human behind the PASA Client needs to visually and/or audioaly/sonically decode the Captcha.

The decode code/captcha is then send back to the server for verification.

Only the server who generated the captcha knows the correct answer/code/captcha.

Once the server establishes that the code was correctly entered the server sends one PASA to the PASA Client.

The client also passes any information required to obtain the free pasa as well as the server so the client can take control of it.
 
## Rationale

No alternate designs are currently functioning. In the past there were web based and telegram based designs all of which have failed or be torn down.

It is time to try and solve this issue once and for all by implementing a stable and long lasting protocol inside the PascalCoin software itself.

The implementation should be flexible enough to allow new/more advanced Captcha plugins to be created in case advanced algorithms and artificial intelligence
successfully decode the captchas.

Captchas are still in use today by many internet/web based services and has proven to be a successfull technique against massive scripting/botting.

## Backwards Compatibility

Since this is a new idea for PascalCoin no backwards compatibility is required, though there may be some existing code/infrastructure that could be re-used
for this purpose.
 
## Reference Implementation

No reference implemention exists yet, first testing the waters if this idea is viable, perhaps main developer can implement most of it if not all of it with
help of captcha generators/plugins.
 
## Links

No references or links as of yet.