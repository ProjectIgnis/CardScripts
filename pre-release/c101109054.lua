--融合超渦
--Fusion Over
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
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_names={CARD_NEOS}
s.listed_series={0x3008,0x1f}
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,tp)
end
function s.cfilter(c,tc,tp)
	if c:IsCode(tc:GetCode(nil,SUMMON_TYPE_FUSION,tp)) then return false end
	return c:IsMonster() and (c:IsSetCard(0x3008) or c:IsSetCard(0x1f) or c:IsLevel(10)) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
	if not cc then return end
	Duel.ConfirmCards(1-tp,cc)
	local code1,code2=cc:GetOriginalCodeRule()
	--Treat its name as the revealed card's if used for a Fusion Summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	e1:SetOperation(s.chngcon)
	tc:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		tc:RegisterEffect(e2)
	end
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_NEOS),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
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