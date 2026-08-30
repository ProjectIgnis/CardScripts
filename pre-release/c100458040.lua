--異解△福音
--Trirealm Rift Gospel
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card by banishing (face-down) 5 cards from your GY and/or the top of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--During your Main Phase, you can Normal Summon 1 "Trirealm Rift" monster, in addition to your Normal Summon/Set (you can only gain this effect once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(function(e,c)
		return c:IsSetCard(SET_XENOVADER)
	end)
	c:RegisterEffect(e2)
	--During your Main Phase: You can banish (face-down) 1 "Trirealm Rift" monster you control whose original Level is 4 or lower, and if you do, Special Summon 1 of your face-down banished Level 5 or higher "Trirealm Rift" monsters. You can only use this effect of "Trirealm Rift Gospel" once per turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.bansptg)
	e3:SetOperation(s.banspop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_XENOVADER}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetDecktopGroup(tp,5)
	local dc=dg:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)
	local gyct=Duel.GetMatchingGroupCount(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil,POS_FACEDOWN)
	if chk==0 then return dc==5 or gyct+dc>=5 end
	local rg=Group.CreateGroup()
	if dc<5 or (gyct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,math.max(5-dc,1),5,nil,POS_FACEDOWN)
		Duel.HintSelection(rg)
	end
	if #rg<5 then
		rg=rg+Duel.GetDecktopGroup(tp,5-#rg)
	end
	Duel.DisableShuffleCheck()
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
function s.banfilter(c,tp)
	return c:IsSetCard(SET_XENOVADER) and c:GetOriginalLevel()<=4 and c:IsAbleToRemove(tp,POS_FACEDOWN) and c:IsFaceup()
		and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(SET_XENOVADER) and c:IsLevelAbove(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.bansptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.banspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.Remove(sc,POS_FACEDOWN,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_REMOVED) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end