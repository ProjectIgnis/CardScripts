--ジョーミノケンタウロース
--Prime Roast Beef Horseman
local s,id=GetID()
function s.initial_effect(c)
	-- fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160006004,160006005)
	-- Damage and draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
	Duel.SortDecktop(tp,tp,#g)
	--gy recover
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,s.rescon,1,tp)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end	
end
function s.thfilter(c)
	return c:IsCode(160006048,160006049,160006050) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160006048)<2 and sg:FilterCount(Card.IsCode,nil,160006049)<2 and sg:FilterCount(Card.IsCode,nil,160006050)<2
end