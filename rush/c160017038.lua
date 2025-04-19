--データーイーター
--Data Eater
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 2 monsters from opponent's GY to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.revfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
function s.revfilter2(c)
	return c:IsMonster() and not c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.revfilter2,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local sg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_HAND,0,nil)
	if #sg<2 then return end
	local tg=aux.SelectUnselectGroup(sg,1,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	Duel.ConfirmCards(1-tp,tg)
	Duel.ShuffleHand(tp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,2,2,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<2 then return end
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tc=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		Duel.HintSelection(tc)
		Duel.BreakEffect()
		--Increase ATK
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.revfilter,nil)==1 and sg:FilterCount(s.revfilter2,nil)==1
end