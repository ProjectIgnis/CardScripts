--ゲーテの魔導書
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.condition)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.activate3)
	e3:SetLabel(3)
	c:RegisterEffect(e3)
end
s.listed_series={0x106e}
s.check=false
function s.rfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	s.check=true
	if chk==0 then return true end
end
function s.filter1(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,ct,nil) 
			and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.filter2(c)
	return not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,ct,nil) 
			and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			Duel.ChangePosition(tc,pos)
		end
	end
end
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,ct,nil) 
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
