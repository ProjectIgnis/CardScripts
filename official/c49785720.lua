--機炎星－ゴヨウテ
--Brotherhood of the Fire Fist - Coyote
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FIRE_FORMATION}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil)
end