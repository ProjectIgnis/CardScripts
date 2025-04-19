--裁きの剣
--Judgment Sword
--Scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x578}
function s.confilter(c)
	return c:GetSequence()>=5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c,e,tp)
	if c:IsHasEffect(EFFECT_SPSUMMON_CONDITION) then
		local sc = c:IsHasEffect(EFFECT_SPSUMMON_CONDITION)
		local v = sc:GetValue()
		if type(v) == 'function' and not v(sc,e,tp,SUMMON_TYPE_SPECIAL) then
			return false
		elseif v == 0 then
			return false
		end
	end
	return c:GetSequence()>=5 and c:IsLinkMonster() and c:IsAbleToRemove()
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and (not c:IsHasEffect(EFFECT_REVIVE_LIMIT) or c:IsStatus(STATUS_PROC_COMPLETE))
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),c:GetSetCard(),c:GetType(),c:GetAttack(),c:GetDefense(),c:GetLevel(),c:GetRace(),c:GetAttribute(),POS_FACEUP,1-tp,SUMMON_TYPE_SPECIAL)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x578) and c:IsLinkMonster() and c:GetLink()==tc:GetLink()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.cfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_REMOVED|LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_REMOVED) and Duel.GetLocationCountFromEx(tp)>0 then
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if g and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			if tc:IsLocation(LOCATION_REMOVED) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) then
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
			elseif tc:IsLocation(LOCATION_REMOVED) and not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) then
				Duel.BreakEffect()
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
	end
end