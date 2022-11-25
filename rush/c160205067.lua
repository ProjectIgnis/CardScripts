--はたらくことのは
--Word Working
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle up to 5 monsters from your opponent's GY to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
function s.filter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:GetFirst():IsLevelAbove(7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_GRAVE,1,5,nil)
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
