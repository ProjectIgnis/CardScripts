--シークレット・パスフレーズ
--Secret Password
--Scripted by AlphaKretin and Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA,SET_EVIL_TWIN,SET_LIVE_TWIN}
function s.thfilter(c,add)
	local c1=(c:IsSetCard(SET_EVIL_TWIN) or c:IsSetCard(SET_LIVE_TWIN)) and c:IsSpellTrap()
	local c2=c:IsSetCard(SET_EVIL_TWIN) and c:IsMonster()
	return (c1 or (add and c2)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local add=g:IsExists(Card.IsSetCard,1,nil,SET_KI_SIKIL) and g:IsExists(Card.IsSetCard,1,nil,SET_LIL_LA)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,add)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local add=g:IsExists(Card.IsSetCard,1,nil,SET_KI_SIKIL) and g:IsExists(Card.IsSetCard,1,nil,SET_LIL_LA)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,add)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end