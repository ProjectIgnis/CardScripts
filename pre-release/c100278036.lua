--ＬＬ－バード・ストライク
--Lyrilusc – Bird Strike
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Negate all of opponent's current monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xf7),tp,LOCATION_MZONE,0,1,nil)end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter1,tp,0,LOCATION_MZONE,1,nil)end end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Lists "Lyrilusc" archetype
s.listed_series={0xf7}
	--Negate all of opponent's current monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.disfilter1,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end