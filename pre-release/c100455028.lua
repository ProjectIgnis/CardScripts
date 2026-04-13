--魔女の聖夜行
--Witchcrafter Walpurgis
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During your Main Phase: You can add 1 "Witchcrafter" monster from your Deck to your hand, then discard 1 card. You can only use this effect of "Witchcrafter Walpurgis" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--During your turn, if you would discard to activate the effect of a "Witchcrafter" monster you control, you can send 1 "Witchcrafter" Spell/Trap from your Deck to the GY instead, except "Witchcrafter Walpurgis"
	local e2=Witchcrafter.CreateCostReplaceEffect(c)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.repcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_WITCHCRAFTER}
function s.thfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.repcostfilter(c)
	return c:IsSetCard(SET_WITCHCRAFTER) and c:IsSpellTrap() and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
function s.repcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(s.repcostfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.repcostfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end