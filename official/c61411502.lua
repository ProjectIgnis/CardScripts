--エレメンタルバースト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spcheck(sg,tp)
	return sg:IsExists(s.chk1,1,nil,sg)
end
function s.chk1(c,sg)
	return c:IsAttribute(ATTRIBUTE_EARTH) and sg:IsExists(s.chk2,1,c,sg,Group.FromCards(c))
end
function s.chk2(c,sg,ex)
	local ex2=ex+c
	return c:IsAttribute(ATTRIBUTE_FIRE) and sg:IsExists(s.chk3,1,ex2,sg,ex2)
end
function s.chk3(c,sg,ex)
	local ex2=ex+c
	return c:IsAttribute(ATTRIBUTE_WATER) and sg:IsExists(Card.IsAttribute,1,ex2,ATTRIBUTE_WIND)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsAttribute,4,false,s.spcheck,nil,ATTRIBUTE_WIND+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_EARTH) end
	local sg=Duel.SelectReleaseGroupCost(tp,Card.IsAttribute,4,4,false,s.spcheck,nil,ATTRIBUTE_WIND+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_EARTH)
	Duel.Release(sg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
