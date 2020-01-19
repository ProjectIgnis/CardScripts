--落とし大穴
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,sp,e)
	return c:IsFaceup() and c:GetSummonPlayer()==sp and (not e or c:IsRelateToEffect(e))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,2,nil,1-tp) end
	local g=eg:Filter(s.cfilter,nil,1-tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil,1-tp,e)
	Duel.SendtoGrave(g,REASON_EFFECT)
	local exg=Group.CreateGroup()
	local g1=Duel.GetOperatedGroup()
	local tc=g1:GetFirst()
	for tc in aux.Next(g1) do
		if tc:IsLocation(LOCATION_GRAVE) then
			local fg=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode())
			exg:Merge(fg)
		end
	end
	Duel.BreakEffect()
	Duel.SendtoGrave(exg,REASON_EFFECT)
end
