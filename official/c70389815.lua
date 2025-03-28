--アメイジングタイムチケット
--Amazing Time Ticket
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(Cost.PayLP(800))
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ATTRACTION,SET_AMAZEMENT}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsTurnPlayer(tp) then
			return s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.settg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if Duel.IsTurnPlayer(tp) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetOperation(s.thop)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetOperation(s.setop)
		s.settg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_AMAZEMENT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.setfilter(c)
	return c:IsSetCard(SET_ATTRACTION) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		local e0=Effect.CreateEffect(tc)
		e0:SetDescription(aux.Stringid(id,0))
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e0)
	end
end