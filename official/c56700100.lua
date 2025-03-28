--ピュアリィ・マイフレンド
--My Friend Purrely
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Reveal 3 "Purrely" cards and add 1 to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.PayLP(500))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Add up to 3 "Purrely" Quick-Play Spells to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rthcond)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_PURRELY}
function s.thfilter(c)
	return c:IsSetCard(SET_PURRELY) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,SET_PURRELY)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end
function s.xyzfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_XYZ) and c:IsPreviousSetCard(SET_PURRELY) and c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp
end
function s.rthcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.xyzfilter,1,nil,tp)
end
function s.qpfilter(c)
	return c:IsSetCard(SET_PURRELY) and c:IsSpell() and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.qpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.qpfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end