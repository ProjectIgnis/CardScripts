--魔雷冥
--Maraimei, the Igniting Inferno
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, take damage and shuffle monsters from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
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
s.listed_names={CARD_SUMMONED_SKULL}
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLevelAbove(6) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c)
	return ((c:IsRace(RACE_FIEND) and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL)) or c:IsCode(CARD_SUMMONED_SKULL)) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,#g*100)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
	--Destroy 1 of opponent's monsters
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_GRAVE,nil)
	if #g>0 then
		Duel.Damage(tp,#g*100,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end