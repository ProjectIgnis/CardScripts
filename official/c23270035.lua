--モンスターアソート
--Assorted Monsters
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)	
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL+TYPE_EFFECT) and c:HasLevel() and c:IsAbleToHand()
end
function s.check(sg,e,tp)
	return sg:GetClassCount(Card.GetRace)==1 and sg:GetClassCount(Card.GetAttribute)==1
		and sg:GetClassCount(Card.GetLevel)==1 and sg:FilterCount(Card.IsType,nil,TYPE_NORMAL)==1
		and sg:FilterCount(Card.IsType,nil,TYPE_EFFECT)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.check,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local g=aux.SelectUnselectGroup(dg,e,tp,2,2,s.check,1,tp,HINTMSG_CONFIRM)
	if #g==2 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tc=g:Select(1-tp,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end