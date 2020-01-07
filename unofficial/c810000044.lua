-- Soul Guide
-- scripted by: UnknownGuest
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	-- recover
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.filter2(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.filter,1,false,nil,nil,tp)
	end
	local tc=Duel.SelectReleaseGroupCost(tp,s.filter,1,1,false,nil,nil,tp):GetFirst()
	local code=tc:GetCode()
	Duel.Release(tc,REASON_COST)
	Duel.SetTargetParam(code)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local rec=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63193879,0))
	local op=Duel.SelectOption(tp,aux.Stringid(70780151,0),aux.Stringid(id,2))
	if op==0 then rec=tc:GetTextAttack()
	else rec=tc:GetTextDefense() end
	if rec<0 then rec=0 end
	Duel.Recover(tp,rec,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,code)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
