--超ちょうカバーカーニバル
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={41440148,11050416}
function s.filter(c,e,tp)
	return c:IsCode(41440148) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.filter,tp,0x13,0,1,nil,e,tp) 
		and (ft==1 or Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0x13,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		if ft>1 and Duel.IsPlayerCanSpecialSummonMonster(tp,11050416,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
			Duel.BreakEffect()
			ft=ft-1
			if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			for i=1,ft do
				local token=Duel.CreateToken(tp,18027138+((i-1)%3+1))
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
				e1:SetRange(LOCATION_MZONE)
				e1:SetTargetRange(0,LOCATION_MZONE)
				e1:SetValue(s.atlimit)
				e1:SetReset(RESET_EVENT+0x3fe0000)
				token:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.atlimit(e,c)
	return not c:IsCode(11050416)
end