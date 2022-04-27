--埋め盾
--Buried Shield
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsCanTurnSet() and tc:IsSummonPlayer(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg:GetFirst(),1,0,0)
end
function s.filter(c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup() 
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
		--Effect
		local tc=eg:GetFirst()
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local tc2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if tc2 then
				-- Update ATK
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc2:RegisterEffectRush(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc2:RegisterEffectRush(e2)
			end
		end
	end
end