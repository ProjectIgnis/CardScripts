--悪魔の印ルーファ
--Lufer the Symbol of the Devils
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.rescon(sg)
	return #sg==2 and not sg:GetFirst():IsRace(sg:GetNext():GetRace())
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsAttackBelow(2500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
		return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,nil) end
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_FACEUP)
	if #tg>0 then
		Duel.HintSelection(tg)
		for tc in tg:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetDescription(3001)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_ONFIELD)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TO_DECK)
			e2:SetValue(1)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_TO_HAND)
			tc:RegisterEffect(e3)
		end
	end
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_MZONE,nil)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160220058) and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g2:Select(tp,1,1,nil)
		if #sg==0 then return end
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg)
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end