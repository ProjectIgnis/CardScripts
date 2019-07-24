--Overlay Dark Reincarnation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,0,1,1,REASON_EFFECT) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp) 
		and Duel.IsPlayerCanDraw(tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.CheckRemoveOverlayCard,tp,0,LOCATION_MZONE,nil,tp,1,REASON_EFFECT)
	if #sg==0 then return end
	local g=Duel.GetOverlayGroup(tp,0,1)
	local mc=g:RandomSelect(tp,1):GetFirst()
	if Duel.SendtoGrave(mc,REASON_EFFECT)>0 then
		if mc:IsAttribute(ATTRIBUTE_DARK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and mc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			if Duel.SpecialSummon(mc,0,tp,tp,false,false,POS_FACEUP)>0 then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		else
			Duel.SetLP(tp,Duel.GetLP(tp)/2)
		end
	end
end
