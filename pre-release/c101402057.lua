--艮神鬼門 三千世界
--Asutrashen Trichiliocosm
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can target any number of face-down cards you control; add "Asutra" cards from your Deck to your hand with different names from each other, except Field Spells, equal to the number of those targeted cards that are still face-down, then send those face-down cards to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If a card(s) becomes Set on the field, while you control an "Asutra" monster and a face-down card: You can target 1 card on the field; return it to the hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_MSET)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(s.rthcon)
	e2a:SetTarget(s.rthtg)
	e2a:SetOperation(s.rthop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetCondition(aux.AND(s.spsuccesscon,s.rthcon))
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_SSET)
	c:RegisterEffect(e2c)
	local e2d=e2a:Clone()
	e2d:SetCode(EVENT_CHANGE_POS)
	e2d:SetCondition(aux.AND(s.changeposcon,s.rthcon))
	c:RegisterEffect(e2d)
end
s.listed_series={SET_ASUTRA}
function s.thfilter(c)
	return c:IsSetCard(SET_ASUTRA) and not c:IsFieldSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local search_group=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #search_group>0 and Duel.IsExistingTarget(aux.AND(Card.IsFacedown,Card.IsAbleToGrave),tp,LOCATION_ONFIELD,0,1,nil) end
	local max_target_count=search_group:GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsFacedown,Card.IsAbleToGrave),tp,LOCATION_ONFIELD,0,1,max_target_count,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#g,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Match(Card.IsFacedown,nil)
	local face_down_count=#tg
	if face_down_count>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if g:GetClassCount(Card.GetCode)<face_down_count then return end
		local sg=aux.SelectUnselectGroup(g,e,tp,face_down_count,face_down_count,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		if #sg==face_down_count and Duel.SendtoHand(sg,nil,REASON_EFFECT)==face_down_count then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ASUTRA),tp,LOCATION_MZONE,0,1,eg)
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
end
function s.spsuccesscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end
function s.changeposconfilter(c)
	return c:IsFacedown() and c:IsPreviousPosition(POS_FACEUP)
end
function s.changeposcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.changeposconfilter,1,nil)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end