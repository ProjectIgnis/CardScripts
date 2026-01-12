--神の見えざる手
--The Hidden Hecahands
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Hecahands" monster from your Deck to your hand, then if you sent a card to the GY at activation, you can Set 1 "Hecahands" Spell/Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Your opponent draws 1 card, then they discard 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drwtg)
	e2:SetOperation(s.drwop)
	c:RegisterEffect(e2)
end
s.listed_seris={SET_HECAHANDS}
s.listed_names={id}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local with_cost=Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,c)
	if with_cost and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,c)
		Duel.SendtoGrave(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_HECAHANDS) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetTargetParam(e:GetLabel())
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.setfilter(c)
	return c:IsSetCard(SET_HECAHANDS) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		if Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)==1 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SSet(tp,sg)
			end
		end
	end
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
		Duel.ShuffleHand(1-tp)
		Duel.BreakEffect()
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end