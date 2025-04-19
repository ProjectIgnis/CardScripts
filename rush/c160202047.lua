--チャーシューティング・スター
--Chashooting Star

local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to targeted monster's level x 200, then return it to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.recfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO) and c:IsLevelAbove(1)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.recfilter),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
	--Gain LP equal to targeted monster's level x 200, then return it to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.recfilter),tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local rec=tc:GetLevel()*200
		if Duel.Recover(tp,rec,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,e:GetHandler())
		end
	end
end