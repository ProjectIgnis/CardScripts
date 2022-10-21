# Modernizing card scripts

Sometimes old cards need to have their Lua script updated due to ruling/functional updates or technical updates (either in the scripting engine or improvements in the ecosystem around it) and oftentimes occurs that these scripts could use a modernization as a whole: They use old idioms, deprecated functionality or simply are not up to the standards that we are used to today.

The following list has been created so that these "modernization steps" are documented somewhere and can be look up for if you are in the mood to improve some script you touched. It is also recommended to consider wether or not a full script rewrite might be worth, in which case, this list also has you covered with common scenarios and examples on what to do.

## Use UTF-8 encoding and Unix line endings

Configure your editor to follow these settings, or make it obey the `.editorconfig` in the root of the repository. Be wary of editing files directly in the browser as it sometimes causes issues with line endings.

## Add missing or update OCG/TCG names

A card script should start with its official Japanese name in the first line as a comment (using Japanese characters, **not** romanized), followed by its official TCG name in English in the next line.

When the card has not yet been imported to the TCG, an unofficial translation must be added as placeholder (try to match the database/proxy name). In the event that the card has not been imported yet to the OCG, leave the Japanese name empty. In both cases however try to update them later once the card is imported to the respective region/scope.

_e.g._:
```lua
--灰流うらら
--Ash Blossom & Joyous Spring
```

## Add descriptions to all activated effects, within reason

TODO (except plain card activations of continuous/field/pendulum spells/traps)

## make effect comments more descriptive and capitalize the first word and some gameplay terms like Special Summon

TODO (combine with top one?)

## Use the `SET_` constants instead of hardcoded values for archetypes

Self explanatory. If the constant doesn't exist, create it. Things to look out for are magic hexadecimal values (_e.g._: `0x26ed`).

## Add timing hints to quick effects

Even though hints do not have a functional impact, they substantially improve the user experience when used properly in key effects. Cards specially affected by this are quick effects that can be activated only in certain phases.

_e.g._:
```lua
--for a Quick Effect that destroys monsters on either field, this would prompt the user when a monster is summoned or an attack is declared.
e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
--for a Quick Effect that can be activated only on the Main Phase, this would prompt the user when the opponent is leaving said phase.
e1:SetHintTiming(0,TIMING_MAIN_END)
```

## Remove Damage Step flag from single+trigger effects

For effects that have its type set as `Effect.SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_*)`(* is either `O` or `F`), the correct Damage Step behavior is already automatically handled in the core, remove the `Effect.SetProperty(EFFECT_FLAG_DAMAGE_STEP)`.

## Remove `if tc` check from targetting effects unless it's mandatory 

TODO (should simply check if tc is related)

## Add `Duel.SetPossibleOperationInfo` to effects that have optional "stuff"

TODO (decide what "stuff" should be)

## Use `Duel.GetMZoneCount` for effects that remove monsters on the field and ~~Special~~ Summon another

TODO (Does it apply to only monsters that Special Summon or could things like immediate normal summons count?)

## Use `Duel.SelectEffect` when choosing effects to apply/activate

Try to use this helper function instead of writing boilerplate code to choose effects (read its documentation). Note that in certain scenarios you should instead use separated effects due to ruling reasons (_e.g._: Daigusto Emeral).

_e.g._:
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

Try to not re-write boilerplate code for a card that detaches Xyz Material(s) as cost, instead, use the aforementioned auxiliary function to generate the function for `Effect.SetCost`, if the situation permits it. Read the documentation of the function for more information.

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

## Use `aux.SelectUnselect` for effects that target/select cards with different filters at the same time

TODO (check "Swordsoul Blackout" and "Marincess Aqua Argonaut" for examples)

## Replace the id in effect codes if they are a magic value meant to be used to interact with other cards

TODO

## Use bitwise operations for values that are meant to be used as bitfields

Constants like location, timing, resets, etc. should be binary or'd (op `|`) instead of just summed (op `+`), because you shouldn't rely on sum carry to set the correct bit in a value.
