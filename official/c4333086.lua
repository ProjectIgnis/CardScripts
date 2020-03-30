--不知火流 燕の太刀
--Shiranui Style Swallow's Slash
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xd9}
function s.filter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.spcheck(sg,tp,exg,dg)
	local a=0
	for c in aux.Next(sg) do
		if dg:IsContains(c) then a=a+1 end
		for tc in aux.Next(c:GetEquipGroup()) do
			if dg:IsContains(tc) then a=a+1 end
		end
	end
	return #dg-a>=2
end
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local dg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,s.spcheck,nil,dg) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		else
			return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local sg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,s.spcheck,nil,dg)
		Duel.Release(sg,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
