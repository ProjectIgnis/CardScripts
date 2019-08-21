--Action Card - Cosmic Arrow
function c150000017.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c150000017.condition)
	e1:SetTarget(c150000017.target)
	e1:SetOperation(c150000017.activate)
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
function c150000017.dfilter(c)
	return c:IsType(TYPE_SPELL)
end
function c150000017.filter(c,e,tp)
	return c:IsControler(tp) and (not c:IsReason(REASON_DRAW)) and (not e or c:IsRelateToEffect(e))
end
function c150000017.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c150000017.filter,1,nil,nil,1-tp)
end
function c150000017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	Duel.SetChainLimit(c150000017.climit)
end
function c150000017.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c150000017.filter,nil,e,1-tp)
	if g:GetCount()==0 then return end
	Duel.ConfirmCards(1-ep,g)
	local dg=g:Filter(c150000017.dfilter,nil)
	Duel.Destroy(dg,REASON_EFFECT)
	Duel.ShuffleHand(ep)
end
function c150000017.climit(e,lp,tp)
	return lp==tp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end