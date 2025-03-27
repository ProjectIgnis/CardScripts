--世海龍ジーランティス
--Worldsea Dragon Zealantis
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 1+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),1)
	--You can only control 1 "Worldsea Dragon Zealantis"
	c:SetUniqueOnField(1,0,id)
	--Banish all monsters on the field, then Special Summon as many monsters as possible that were banished by this effect, to their owners' fields, face-up, or in face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmsptg)
	e1:SetOperation(s.rmspop)
	c:RegisterEffect(e1)
	--Destroy cards on the field up to the number of co-linked monsters on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsBattlePhase() end)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	local owner=c:GetOwner()
	return c:IsFaceup() and c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,owner))
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local sg=og:Filter(s.spfilter,nil,e,tp)
		if #sg==0 then return end
		local your_sg,opp_sg=sg:Split(Card.IsOwner,nil,tp)
		local your_ft,opp_ft=Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if #your_sg>your_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			your_sg=your_sg:Select(tp,your_ft,your_ft,nil)
		end
		if #opp_sg>opp_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			opp_sg=opp_sg:Select(tp,opp_ft,opp_ft,nil)
		end
		sg=your_sg+opp_sg
		for sc in sg:Iter() do
			local sump=0
			local owner=sc:GetOwner()
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner) then sump=sump|POS_FACEUP end
			if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,owner) then sump=sump|POS_FACEDOWN_DEFENSE end
			Duel.SpecialSummonStep(sc,0,tp,owner,false,false,sump)
		end
		local fdg=sg:Filter(Card.IsFacedown,nil)
		if #fdg>0 then
			Duel.ConfirmCards(1-tp,fdg)
		end
		Duel.BreakEffect()
		Duel.SpecialSummonComplete()
	end
end
function s.desctfilter(c)
	return c:GetMutualLinkedGroupCount()>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #dg>0 and Duel.IsExistingMatchingCard(s.desctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.desctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end