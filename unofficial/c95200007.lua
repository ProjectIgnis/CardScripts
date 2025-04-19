--Command Duel 7
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsTrap() and c:IsSSetable()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_DECK,0,nil)
	if #g1>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(60082869,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.SSet(tp,sg1:GetFirst())
	end
	if #g2>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(60082869,0)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)
		local sg2=g2:Select(1-tp,1,1,nil)
		Duel.SSet(1-tp,sg2:GetFirst())
	end
end