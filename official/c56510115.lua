--ドレミコード・シンフォニア
--Solfachord Symphony
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SOLFACHORD,SET_GRANSOLFACHORD}
function s.solfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SOLFACHORD),tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetMatchingGroup(s.solfilter,tp,LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)>2 end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GRANSOLFACHORD) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(s.solfilter,tp,LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)
	if ct<3 then return end
	local breakeff=false
	local c=e:GetHandler()
	--"Solfachord" Pendulum Monsters gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(function(e,c) return c:GetScale()*300 end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if ct<5 then return end
	--Destroy 1 card
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local pg=g:Select(tp,1,1,nil)
		if #pg>0 then
			Duel.BreakEffect()
			if Duel.Destroy(pg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsOddScale,tp,LOCATION_PZONE,0,1,nil) then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			breakeff=true
		end
	end
	if ct<7 then return end
	--Special Summon 1 "GranSolfachord" monster
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssg=sg:Select(tp,1,1,nil)
		if #ssg==0 then return end
		if breakeff then Duel.BreakEffect() end
		Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atktg(e,c)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM)
end