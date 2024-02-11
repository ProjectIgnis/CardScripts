--セレブ・リベレイション
--Celeb Revelation
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter1(c)
	return c:IsEquipSpell() and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.filter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.tdfilter(c)
	if not c:IsAbleToDeckOrExtraAsCost() then return false end
	if c:IsLocation(LOCATION_ONFIELD) then return c:IsFaceup() and c:IsEquipSpell() end
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.rescon(sg,e,tp,mg)
	return (sg:FilterCount(s.filter1,nil)==1 and sg:FilterCount(s.filter2,nil)==0)
		or (sg:FilterCount(s.filter1,nil)==0 and sg:FilterCount(s.filter2,nil)==4)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,4,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(sg,true)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<1 then return end
	--Effect
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=g:Select(tp,1,3,nil)
		sg=sg:AddMaximumCheck()
		if #sg>0 then
			Duel.HintSelection(sg,true)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end