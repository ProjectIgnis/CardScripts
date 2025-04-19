--ゾンビ・ファイヤーワーク
--Zombie Fireworks
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.zfilter(c,cost)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(5)
		and ((cost and not c:IsPublic()) or c:IsAbleToGrave())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_HAND,0,1,nil,true) end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_HAND,0,1,nil,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Prevent non-Zombies from attacking
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ATTACK)
	e0:SetProperty(EFFECT_FLAG_OATH)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return not c:IsRace(RACE_ZOMBIE) end)
	e0:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.zfilter,tp,LOCATION_HAND,0,1,1,nil,true):GetFirst()
	if rc then
		Duel.ConfirmCards(1-tp,rc)
		Duel.ShuffleHand(tp)
	end
	--Effect
	local ft=Duel.GetMZoneCount(tp)
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,math.min(ft,2),nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.zfilter,tp,LOCATION_HAND,0,1,1,nil,false)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end