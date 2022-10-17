# Modernizing card scripts

Sometimes old cards need to have their Lua script updated due to rulling/functional updates or technical updates (either in the scripting engine or improvements in the ecosystem around it) and oftentimes occurs that these scripts could use a modernization as a whole: They use old idioms, deprecated functionality or simply are not up to the standards that we are used to today.

The following list has been created so that these "modernization steps" are documented somewhere and can be look up for if you are in the mood to improve some script you touched. It is also recommended to consider wether or not a full script rewrite might be worth, in which case, this list also has you covered with common scenarios and examples on what to do.

## Use UTF-8 encoding and Unix line endings

Configure your editor to follow these settings, or make it obey the `.editorconfig` in the root of the repository. Be wary of editing files directly in the browser as it sometimes causes issues with line endings.

## Add missing or update OCG/TCG names

A card script should start with its official Japanese name in the first line as a comment (using Japanese characters, **not** romanized), followed by its official TCG name in English in the next line.

When the card has not yet been imported to the TCG, an unnofficial translation must be added as placeholder (try to match the database/proxy name). In the event that the card has not been imported yet to the OCG, leave the Japanese name empty. In both cases however try to update them later once the card is imported to the respective region/scope.

_e.g._:
```lua
--灰流うらら
--Ash Blossom & Joyous Spring
```

## Add descriptions to all activated effects, within reason

except plain card activations of continuous/field/pendulum spells/traps

TODO

- add descriptions to all activated effects ()
- make effect comments more descriptive and capitalize the first word and some gameplay terms like Special Summon
- use the new SET_ constants
- add hint timing to quick effects
- remove the damage step flag from single+trigger effects
- remove the if tc from targetting effects unless it's mandatory (should simply check if tc is related)
- add Duel.SetPossibleOperationInfo to effects that have optional stuff
- use Duel.GetMZoneCount for effects that remove monsters on the field and Special Summon another
- use Duel.SelectEffect for choosing effects to apply/activate
- use aux.dxmcostgen for simple detachment costs
- use aux.selfreleasecost for cards that only tribute themselves as cost
- check for Card.IsCanBeXyzMaterial for effects that attach
- use aux.SelectUnselect for effects that target/select cards with different filters at the same time (check "Swordsoul Blackout" and "Marincess Aqua Argonaut" for examples)
- replace all the id in effect codes if the effect code is a magic value meant to be used to interact with other cards
- use bitwise operations for values that are meant to be used as bitfields
