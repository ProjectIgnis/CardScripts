--解呪の神碑
--Runick Dispelling
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1,e2=Effect.CreateMysteruneQPEffect(c,id,CATEGORY_TOGRAVE+CATEGORY_HANDES,s.tgtg,s.tgop,2,EFFECT_FLAG_DELAY,EVENT_TO_HAND)
	e1:SetCondition(s.tgcon)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RUNICK}
function s.tgconfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.tgconfilter,1,nil,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		local sg=g:RandomSelect(1-tp,1)
		return #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)>0
	end
end