--融合超渦
--Over Fusion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS}
s.listed_series={SET_ELEMENTAL_HERO,SET_NEO_SPACIAN}
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,nil,c,tp)
end
function s.cfilter(c,tc,tp)
	if c:IsCode(tc:GetCode(nil,SUMMON_TYPE_FUSION,tp)) then return false end
	return c:IsMonster() and (c:IsSetCard({SET_ELEMENTAL_HERO,SET_NEO_SPACIAN}) or c:IsLevel(10)) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
	if not cc then return end
	Duel.ConfirmCards(1-tp,cc)
	local code1,code2=cc:GetOriginalCodeRule()
	--Treat its name as the revealed card's if used for a Fusion Summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(code1)
	e1:SetOperation(s.chngcon)
	tc:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		tc:RegisterEffect(e2)
	end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_NEOS),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) then
		Duel.SendtoGrave(cc,REASON_EFFECT)
	elseif cc:IsLocation(LOCATION_HAND) then
		Duel.SendtoDeck(cc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	if cc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp)
	elseif cc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp)
	elseif cc:IsLocation(LOCATION_EXTRA) then Duel.ShuffleExtra(tp) end
end
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end