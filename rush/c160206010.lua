--レジェンド・セイバー
--Legend Saber
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--This turn, this card can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsLegend() and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)==0 then return end
	--Effect
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Decrease ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffectRush(e1)
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
				--Prevent monsters from attacking
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_ATTACK)
				e2:SetTargetRange(LOCATION_MZONE,0)
				e2:SetTarget(function(_,c) return not (c:IsRace(RACE_CELESTIALWARRIOR) or c:IsRace(RACE_WARRIOR)) end)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end