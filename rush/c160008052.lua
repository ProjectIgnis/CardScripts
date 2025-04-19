--逆鱗火斬
--Fire Wrath
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 face-up monster on your opponent's field with an equal or lower Level than the total Level of the monsters sent to the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_REPTILE) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND,0,1,c,tp,c:GetLevel())
end
function s.costfilter2(c,tp,lv)
	return c:IsMonster() and c:IsRace(RACE_REPTILE) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,(lv+c:GetLevel()))
end
function s.desfilter(c,lvl)
	return c:IsFaceup() and c:IsLevelBelow(lvl) and not c:IsMaximumModeSide()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.desfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
function s.tgfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_REPTILE) and c:IsAbleToGraveAsCost()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SELECT)
	if Duel.SendtoGrave(tg,REASON_EFFECT) then
		local lvl=tg:GetSum(Card.GetOriginalLevel)
		local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter,lvl),tp,0,LOCATION_MZONE,e:GetHandler())
		if dg and #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,sg:GetSum(Card.GetOriginalLevel))
end