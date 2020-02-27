--Dimension Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=1000
end
function s.filter(c,g,tp)
	local mg=g:Filter(Card.IsCode,nil,c:GetCode())
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.mfilter(c,g,tg,ct,tp)
	local mg=g:Filter(Card.IsCode,nil,c:GetCode())
	local xct=ct+1
	mg:RemoveCard(c)
	tg:AddCard(c)
	local res=false
	if xct==3 then
		local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tg)
	else
		local res=mg:IsExists(s.mfilter,1,c,mg,tg,xct,tp)
	end
	tg:RemoveCard(c)
	return res
end
function s.xyzfilter(c,g)
	return c:IsXyzSummonable(nil,g,3,3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x1e,0,nil)
	if chk==0 then return g:IsExists(s.filter,1,nil,g,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x1e,0,nil)
	local mg=g:Filter(s.filter,nil,g,tp)
	local matg=Group.CreateGroup()
	for i=1,3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=mg:FilterSelect(tp,s.mfilter,1,1,nil,mg,matg,i-1,tp)
		local tc=sg:GetFirst()
		mg=mg:Filter(Card.IsCode,nil,tc:GetCode())
		matg:AddCard(tc)
		mg:RemoveCard(tc)
	end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,matg)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		matg:KeepAlive()
		Duel.XyzSummon(tp,xyz,nil,matg)
	end
end
