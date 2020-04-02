--六花絢爛
--Rikka Glamour
--scripted by Naim, updated by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
s.listed_series={0x141}
function s.filter(c,e,tp,check)
	return c:IsSetCard(0x141) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (check==0 or Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,c:GetOriginalLevel(),c:GetCode()))
end
function s.filter2(c,lv,code)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:GetOriginalLevel()==lv and not c:IsCode(code)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,1)
	if chk==0 then return a or b end
	if b and Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,nil,nil,RACE_PLANT)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,false,nil,nil,RACE_PLANT)
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel()+1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		local lv=g:GetFirst():GetOriginalLevel()
		local code=g:GetFirst():GetCode()
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if e:GetLabel()==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,lv,code)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end
