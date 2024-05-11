--ホルスの先導－ハーピ
--Hapi, Guidance of Horus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the GY if you control "King's Sarcophagus"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Add to the hand or shuffle into the Deck 2 cards that are banished or in the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thtdcon)
	e2:SetTarget(s.thtdtg)
	e2:SetOperation(s.thtdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_KING_SARCOPHAGUS}
function s.spcon(e,c)
	if c==nil then return true end
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_KING_SARCOPHAGUS),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.thtdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAbleToHand,nil)==#sg or sg:FilterCount(Card.IsAbleToDeck,nil)==#sg
end
function s.thtdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,sg,2,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,sg,2,tp,0)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,rg,#rg,0,0)
	end
end
function s.thtdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=2 then return end
	local b1=g:FilterCount(Card.IsAbleToHand,nil)==2
	local b2=g:FilterCount(Card.IsAbleToDeck,nil)==2
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)}, --"Add both to the hand"
		{b2,aux.Stringid(id,3)}) --"Shuffle both into the Deck"
	if op==1 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	else
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end