# Modernizing card scripts

Sometimes old cards need to have their Lua script updated due to ruling, functional, and/or technical updates (either in the scripting engine or improvements in the ecosystem around it), and oftentimes, it would turn out that said scripts could use a modernization as a whole: they use old idioms, deprecated functionality, and/or are simply not up to the standards that we are used to today.

The following list has been created so that these "modernization steps" are documented somewhere and can be looked up if you are in the mood to improve some script you touched. It is also recommended to consider whether or not a full script rewrite might be worth it, in which case, this list also has you covered with common scenarios and examples of things to keep in mind when doing so.

## Use UTF-8 encoding and Unix line endings

Configure your editor to follow these settings, or make it obey the `.editorconfig` in the root of the repository. Be wary of editing files directly in the browser as it sometimes causes issues with line endings.

## Add missing or update OCG/TCG names

A card script should start with its official Japanese name in the first line as a comment (using Japanese characters, **not** romanized), followed by its official TCG name in English in the next line.

When the card has not yet been imported to the TCG regions, an unofficial translation must be added as placeholder, matching the database/proxy name. In the event that the card has not been imported yet to the OCG, leave the Japanese name empty. In both cases however, try to update them later once the card is imported to the respective region/scope. _e.g._:

```lua
--灰流うらら
--Ash Blossom & Joyous Spring
```

## Add descriptions to (almost) every activated effect

Activated effects should have their own descriptions, set through `Effect.SetDescription`. Previously, they were usually not set if a card has only one activated effect of a given type, the idea being that there is no need to differentiate between effects if there is only one. Nowadays however, it is not too uncommon for cards to gain additional effects mid-duel through copying and granting effects, or for other cards to apply other cards' effects. 

Rather than trying to think of such or similar scenarios in each individual script, it it more practical to simply be consistent about it and have a description explicitly associated to each activated effect. It also has the added benefit of letting AI frameworks like Windbot properly check which effect is which through their descriptions.

The exceptions to this are the activations of Field Spells, Continuous Spells, Pendulum Spells, _i.e._, their `EFFECT_TYPE_ACTIVATE` effects that place them face-up on the field.

Note that their database strings would also have to be updated to add the missing strings for the new descriptions, especially if some older strings need to be moved up to match the script (string `0` may become string `1` due to a newly-added description).

## Make effect comments more descriptive

Comments such as "sp.summon" and "draw" are not very useful to describe what an effect is supposed to do. Detailed versions of what the effect is supposed to do are preferred, using at most 1 line. The first word and gameplay terms that are capitalized in the rulebook should be capitalized. _e.g._:

```lua
--Special Summon 1 "tellarknight" monster from the Deck
```

## Use the `SET_` constants instead of hardcoded values for archetypes

If a card script uses a setcode, replace its hexadecimal value by the corresponding constant name obtained from our [list of archetype constants](https://github.com/ProjectIgnis/CardScripts/blob/master/archetype_setcode_constants.lua). If the matching constant does not exist, it should be created.

## Add timing hints to quick effects

Even though hints do not have a functional impact, they substantially improve the user experience when used properly in key effects. Effects that should specially be considered for this are quick effects that can be activated only in certain phases. _e.g._:

```lua
--for a Quick Effect that destroys monsters on either field, this would prompt the user when a monster is summoned or an attack is declared.
e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
--for a Quick Effect that can be activated only in the Main Phase, this would prompt the user when the opponent is leaving said phase.
e1:SetHintTiming(0,TIMING_MAIN_END)
```

## Remove the Damage Step flag from SINGLE+TRIGGER effects

For effects that have their type set as `EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_*` (* is either `O` or `F`), the correct Damage Step behavior is already automatically handled in the core, remove the `EFFECT_FLAG_DAMAGE_STEP` in the `SetProperty` call.
Exceptions to this can be made based on rulings. _e.g._: "Proof of Pruflas" and "Fusion Parasite" are single effects ruled not to be activatable in the Damage Step.

## Remove `if tc` check from targetting effects unless it's mandatory 

Effects that target should always have access to the target in the operation, unless something goes wrong. By using `if tc`, this is obscured and might cause misinteractions that can be missed, as script errors might not be generated. Such a check should be kept only in cards that are mandatory trigger effects (where the target might not exist), otherwise only the `Card.IsRelateToEffect` should be used. _e.g._:

Change:
```lua
local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) then
	--do things
end
```
to:
```lua
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e) then
	--do things
end
```

## Add `Duel.SetPossibleOperationInfo` to effects that have optional or not guaranteed parts in the resolution

`Duel.SetPossibleOperationInfo` was introduced to deal with cards that detect effects which 'include doing X', when only detecting the effect category is not enough. As such, if an effect has any optional part of its resolution that could be informed via `Duel.SetOperationInfo` if it was mandatory, then that information should be set via `Duel.SetPossibleOperationInfo`. _e.g._: "Veil of Darkness" (optional draw in the resolution), "Supay Duskwalker" (optional Special Summon from the hand or Deck).


## Use `Duel.GetMZoneCount` for effects that remove monsters on the field and Summon another

If an effect summons a monster but requires (either by effect or by cost) removing another another monster from the field (_e.g._: Tributing/banishing/destroying it, etc) before performing the summon, using only `Duel.GetLocationCount` will not be enough to account for the possibility of that monster removed setting free a Monster Zone. Instead, `Duel.GetMZoneCount` should be used, providing it the matching exclusion parameter to properly handle these interactions. _e.g._: "Condemned Witch".

## Use `Duel.SelectEffect` when choosing effects to apply/activate

Try to use this helper function instead of writing boilerplate code to choose effects (read its documentation).
Confirm if the effect should be kept as separated effects due to ruling reasons (_e.g._: "Daigusto Emeral").

Another example:
```lua
local b1=true --Some condition 1.
local b2=false --Some condition 2. 
local op=Duel.SelectEffect(tp,
	{b1,aux.Stringid(id,1)},
	{b2,aux.Stringid(id,2)},
	{b1 and b2 and e:GetLabel()==0,aux.Stringid(id,3)})
if op==1 then
	--Do something for first choice.
elseif op==2 then
	--Do something for second choice.
elseif op==3 then
	--Do something for third choice.
end
e:SetLabel(op) --Potentially do something else with the choice down the line.
```

## Use `aux.dxmcostgen` for simple detachment costs

Try not to re-write boilerplate code for a card that detaches an Xyz Material(s) as cost, instead, use the aforementioned auxiliary function to generate the function for `Effect.SetCost`, if the situation permits it. Read the documentation of the function for more information.

_e.g._:
```lua
--"detach 1 Xyz material from this card;"
e1:SetCost(aux.dxmcostgen(1,1,nil))
--"detach 2 Xyz materials from this card + Other cost;
e1:SetCost(aux.AND(aux.dxmcostgen(1,1,nil),s.othercost))
```

## Use `aux.selfreleasecost` for cards that tribute only themselves as cost

_e.g._:
```lua
--"You can Tribute this card;"
e1:SetCost(aux.selfreleasecost)
```

## Use `Card.IsCanBeXyzMaterial` on effects that attach

Do not simply call `Duel.Overlay` or `Card.Overlay`, first check if the card(s) can be attached with the aforementioned function.

## Use `aux.SelectUnselectGroup` for effects that target/select cards with different filters at the same time

If an effect targets/selects cards that must meet different criteria at the same time, `SelectUnselectGroup` provides a clean way to do it, possibly shortening the script and/or avoiding multiple nested filters. _e.g._: "Swordsoul Blackout", "Marincess Aqua Argonaut" and "Ninjitsu Art Notebook of Mystery".

## Replace the id in effect codes if they are a magic value meant to be used to interact with other cards

If a card needs to check for effects hardcoded as the ID of the card that implements them, the corresponding constant should be used instead of such id. If the constant does not exist and the effect is commonly used, it should be created and put in `constant.lua`. _e.g._:

Change:
```lua
if c:IsHasEffect(61777313) then
	--do things
end
```
to
```lua
if c:IsHasEffect(EFFECT_SYNSUB_NORDIC) then
	--do things
end
```

## Use bitwise operations for values that are meant to be used as bitfields

Constants like location, timing, resets, etc. should be binary or'd (op `|`) instead of just summed (op `+`), because you shouldn't rely on sum carry to set the correct bit in a value.

## Remove the `IsRelateToEffect` check from cards that need to remain face-up to resolve their effects

The behaviour of continuous-like Spells/Traps which must remain face-up on the field to resolve their activated effects is now automatically handled in the core, rendering the check redundant. Plus, in the off chance that another card/effect can apply that effect's operation function that check existing could cause wrong interactions in some cases.
