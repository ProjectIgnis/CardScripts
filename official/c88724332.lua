--ナイト・ドラゴリッチ
--Night Dragolich
local s,id=GetID()
function s.initial_effect(c)
	--Change all non-Wyrm Attack Position monsters that were Special Summoned from the Main or Extra Deck to Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsFaceup() and not c:IsRace(RACE_WYRM) and c:IsSpecialSummoned() and c:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA) end)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e1)
	--All non-Wyrm monsters that were Special Summoned from the Main or Extra Deck lose DEF equal to their original DEF
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(function(e,c) return -c:GetBaseDefense() end)
	c:RegisterEffect(e2)
end
