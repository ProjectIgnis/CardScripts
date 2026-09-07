--レーン・リストリクション
--Lane Restriction
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can Special Summon 1 of your banished monsters to your rightmost Main Monster Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If your opponent would Normal or Special Summon a monster(s) to their Main Monster Zone, they must use the leftmost unused zone(s)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_FORCE_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.forcemzoneval)
	c:RegisterEffect(e2)
end
local offset=Duel.IsDuelType(DUEL_3_COLUMNS_FIELD) and 1 or 0
local LEFTMOST_SEQ=0+offset
local RIGHTMOST_SEQ=4-offset
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spfilter(c,e,tp,rightmost_zone)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,rightmost_zone)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rightmost_zone=1<<RIGHTMOST_SEQ
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,nil,rightmost_zone)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp,rightmost_zone)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP,rightmost_zone)
		end
	end
end
function s.forcemzoneval(e,fp,rp,r)
	--Needs to somehow not affect Normal Sets, no way to do that atm
	local opp=1-e:GetHandlerPlayer()
	for seq=LEFTMOST_SEQ,RIGHTMOST_SEQ do
		if Duel.CheckLocation(opp,LOCATION_MZONE,seq) then
			return (1<<seq)|ZONES_EMZ|(ZONES_MMZ<<16)
		end
	end
	return ZONES_EMZ|(ZONES_MMZ<<16)
end