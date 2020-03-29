--地殻変動
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.desfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		if #g==0 then return false end
		local tc=g:GetFirst()
		local att=0
		for tc in aux.Next(g) do
			att=(att|tc:GetAttribute())
		end
		return (att&att-1)~=0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #sg==0 then return false end
	local tc=sg:GetFirst()
	local att=0
	for tc in aux.Next(sg) do
		att=(att|tc:GetAttribute())
	end
	if (att&att-1)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local att1=Duel.AnnounceAttribute(tp,2,att)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATTRIBUTE)
	local att2=Duel.AnnounceAttribute(1-tp,1,att1)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,att2)
	Duel.Destroy(g,REASON_EFFECT)
end
