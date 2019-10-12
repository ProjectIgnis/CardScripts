--カバーカーニバル (Anime)
--Hippo Carnival (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={11050416}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		for i=1,3 do
			local token=Duel.CreateToken(tp,18027138+i)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			--atk limit
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsCode,11050416)))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end