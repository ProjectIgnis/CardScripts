-- 警告鱗光
--Warning Scale Phosphorescence
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, prevent attack and shuffle monsters from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
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
function s.filter1(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLevelAbove(7) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup() 
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.gyfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_REPTILE) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

	--Destroy 1 of opponent's monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	--cannot attack
		local ge1=Effect.CreateEffect(e:GetHandler())
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetTargetRange(0,LOCATION_MZONE)
		ge1:SetTarget(s.atktg)
		ge1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(ge1,tp)
		local og=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
		if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=og:Select(tp,1,5,nil)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
end
function s.atktg(e,c)
	return c:IsAttackBelow(3000)
end