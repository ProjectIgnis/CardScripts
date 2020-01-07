--ロイヤル・ストレート・スラッシャー
--Royal Straight Slasher
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85771019,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={511000088}
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(511000088)
end
function s.desfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==1 and c:IsAbleToGrave()
end
function s.desfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==2 and c:IsAbleToGrave()
end
function s.desfilter3(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==3 and c:IsAbleToGrave()
end
function s.desfilter4(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==4 and c:IsAbleToGrave()
end
function s.desfilter5(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()==5 and c:IsAbleToGrave()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter1,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter2,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter3,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter4,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.desfilter5,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.desfilter1,tp,LOCATION_DECK,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.desfilter2,tp,LOCATION_DECK,0,1,1,nil)
	local g3=Duel.SelectMatchingCard(tp,s.desfilter3,tp,LOCATION_DECK,0,1,1,nil)
	local g4=Duel.SelectMatchingCard(tp,s.desfilter4,tp,LOCATION_DECK,0,1,1,nil)
	local g5=Duel.SelectMatchingCard(tp,s.desfilter5,tp,LOCATION_DECK,0,1,1,nil)
	g1:Merge(g2)
	g1:Merge(g3)
	g1:Merge(g4)
	g1:Merge(g5)
	if #g1==5 then
		Duel.SendtoGrave(g1,REASON_COST)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
