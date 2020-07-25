--ロード・マジック－ダイアストロフィズム
--Road Magic - Diastrophism
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup(),tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST)>0 then
		--Effect
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
		if #g==0 then return end
		local tc=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_MONSTER):GetFirst()
		local gc=g:GetMaxGroup(Card.GetAttack):GetFirst()
		if tc and gc then
			local atk=gc:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-atk)
			tc:RegisterEffect(e1)
		end
	end
end