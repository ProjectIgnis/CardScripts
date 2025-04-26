--Ｓｉｎ Ｓｅｌｅｃｔｏｒ
--Malefic Selector
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Add 2 "Malefic" cards from your Deck to your hand, except "Malefic Selector", with different names from each other and from the banished cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MALEFIC}
s.listed_names={id}
function s.costfilter(c)
	return c:IsSetCard(SET_MALEFIC) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	if #sg~=2 then return false end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,sg:GetFirst():GetCode(),sg:GetNext():GetCode())
	return g:GetClassCount(Card.GetCode)>1
end
function s.thfilter(c,code1,code2)
	return c:IsSetCard(SET_MALEFIC) and not c:IsCode(id,code1,code2) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetFirst():GetCode(),rg:GetNext():GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local code1,code2=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,code1,code2)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg==2 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
