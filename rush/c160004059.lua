--ジュエリーの落とし穴
--Jewelry Trap Hole
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, destroy 1 of opponent's face-up level 8 or lower monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
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
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_AQUA),tp,LOCATION_MZONE,0,3,nil)
end
function s.desfilter(c)
	return c:IsMonster() and c:IsLevelBelow(8) and not c:IsMaximumModeSide() and c:IsFaceup()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
end
	--Destroy 1 of opponent's monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	local sg=dg:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		sg=sg:AddMaximumCheck()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end