--電網の落とし穴
--Network Trap Hole
--
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return not c:IsSummonPlayer(tp) and not (c:IsSummonLocation(LOCATION_DECK) or c:IsSummonLocation(LOCATION_GRAVE))
		and c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsLocation(LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil,tp)
	local ct=#g
	if chk==0 then return ct>0 end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

