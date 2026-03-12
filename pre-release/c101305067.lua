--三幻魔の神淵
--Divine Abyss of the Sacred Beast
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can send 3 face-up "Divine Abyss of the Sacred Beast" you control to the GY, including this card, then target 1 face-up monster your opponent controls; change it to face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCost(s.poscost)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During the Main Phase: You can place 2 "Divine Abyss of the Sacred Beast" from your hand, Deck, and/or GY face-up on your field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--During your opponent's End Phase, if this card is in your GY: You can place it on the bottom of the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp) return Duel.IsEndPhase(1-tp) end)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.poscostfilter(c)
	return c:IsCode(id) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED)
		and Duel.IsExistingMatchingCard(s.poscostfilter,tp,LOCATION_ONFIELD,0,2,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.poscostfilter,tp,LOCATION_ONFIELD,0,2,2,c)
	Duel.SendtoGrave(g+c,REASON_COST)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsMonster() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.selfplfilter(c,tp)
	return c:IsCode(id) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		and Duel.IsExistingMatchingCard(s.selfplfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.selfplfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,2,nil,tp)
	if #g==2 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.MoveToField(g:GetNext(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end