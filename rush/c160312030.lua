--ジョインテック・バンパー
--Jointech Bumper
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_NORMAL) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and not c:IsMaximumModeSide()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,3,nil)
		sg=sg:AddMaximumCheck()
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end