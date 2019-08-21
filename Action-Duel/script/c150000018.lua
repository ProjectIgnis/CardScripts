--Action Card - Crush Action
function c150000018.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c150000018.target)
	e1:SetOperation(c150000018.activate)
	c:RegisterEffect(e1)
	--become action card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_QUICKPLAY)
	c:RegisterEffect(e3)
end
function c150000018.filter(c)
	return c:IsSetCard(0xac1)
end
function c150000018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(c150000018.filter,tp,0,LOCATION_HAND,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c150000018.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(c150000018.filter,tp,0,LOCATION_HAND,nil)
	Duel.Destroy(sg,REASON_EFFECT)  
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58481572,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCondition(c150000018.hdcon)
	e3:SetOperation(c150000018.hdop)
	Duel.RegisterEffect(e1,tp)
end
function c150000018.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xac1)
end
function c150000018.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c150000018.cfilter,1,nil,1-tp)
end
function c150000018.hdop(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(c150000018.cfilter,nil,1-tp)
	if g:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end