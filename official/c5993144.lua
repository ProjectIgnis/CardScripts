--スワローズ・カウリー
--Swallow's Cowrie
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 Winged Beast monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c,tp)
	return c:IsRace(RACE_WINGEDBEAST) and c:HasLevel() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
function s.thfilter(c,lv)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsLevel(lv) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,true,nil,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,true,nil,nil,tp):GetFirst()
	e:SetLabel(tc:GetLevel())
	Duel.Release(tc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabel()==100 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end