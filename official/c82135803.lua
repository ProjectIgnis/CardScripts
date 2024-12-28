--刻まれし魔ディエスイレ
--Fiendsmith's Desirae
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials
	Fusion.AddProcMixN(c,true,true,60764609,1,s.matfilter,2)
	--Negate the effects of face-up cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Send 1 card on the field to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_names={60764609} --"The Fiendsmith"
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) and c:IsRace(RACE_FIEND,fc,sumtype,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():Match(Card.IsFaceup,nil):GetSum(Card.GetLink,nil)>0
		and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=c:GetEquipGroup():Match(Card.IsFaceup,nil):GetSum(Card.GetLink,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	for tc in g:Iter() do
		--Negate its effects until the end of this turn
		tc:NegateEffects(c,RESET_PHASE|PHASE_END,true)
	end
end
function s.tgcostfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) and c:IsAbleToDeckOrExtraAsCost()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgcostfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tgcostfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end