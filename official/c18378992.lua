--Ｓｉｎ Ｓｅｌｅｃｔｏｒ
--Malefic Selector
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Add 2 "Malefic" cards from the Deck to the hand
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
function s.cfilter(c)
	return c:IsSetCard(SET_MALEFIC) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.thfilter(c,g)
	return c:IsSetCard(SET_MALEFIC) and not c:IsCode(id) and c:IsAbleToHand() and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.rescon(sg,e,tp,mg)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,sg)
	return g:GetClassCount(Card.GetCode)>1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then e:SetLabel(0) return false end
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil,tp)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil,tp)
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	rg:KeepAlive()
	e:SetLabelObject(rg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=e:GetLabelObject()
	local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,rg)
	local g=aux.SelectUnselectGroup(hg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #g==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	rg:DeleteGroup()
end