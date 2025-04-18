--セイヴァー・ミラージュ
--Majestic Mirage
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Apply effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={id,CARD_STARDUST_DRAGON}
function s.lffilter(c,tp,re)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_COST) and re and re:IsActivated()))
		and (c:IsCode(CARD_STARDUST_DRAGON) or (c:ListsCode(CARD_STARDUST_DRAGON) and c:IsType(TYPE_SYNCHRO)))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:IsExists(s.lffilter,1,nil,tp,re)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and c:IsMonster()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.lffilter,nil,tp,re):Match(s.spfilter,nil,e,tp)
	local b1=#g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
	Duel.SetTargetCard(g)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.lffilter,nil,tp,re):Match(s.spfilter,nil,e,tp):Match(Card.IsRelateToEffect,nil,e)
	local b1=#g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	local sg=nil
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=g:Select(tp,1,1,nil,e,tp)
		if #sg==0 or Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		sg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_GRAVE|LOCATION_MZONE,1,1,nil)
		if #sg==0 then return end
		Duel.HintSelection(sg,true)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	elseif op==3 then
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		--Halve damage
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(function(e,re,ev) return math.floor(ev/2) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end