--同姓同名同盟条約
--Treaty on Uniform Nomenclature
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x11e0) --0x1000+0x100+0x80+0x40+0x20
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
function s.get_count(g)
	if #g==0 then return 0 end
	local ret=0
	repeat
		local tc=g:GetFirst()
		g:RemoveCard(tc)
		local ct1=#g
		g:Remove(Card.IsCode,nil,tc:GetCode())
		local ct2=#g
		local c=ct1-ct2+1
		if c>ret then ret=c end
	until #g==0 or #g<=ret
	return ret
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=s.get_count(g)
	e:SetLabel(ct)
	return ct==2 or ct==3
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	if e:GetLabel()==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=s.get_count(g)
	if ct==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.Destroy(g,REASON_EFFECT)
	elseif ct==3 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
