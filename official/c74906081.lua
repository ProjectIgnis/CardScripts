--睨み統べるスネークアイズ
--Startling Stare of the Snake-Eyes
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SNAKE_EYE}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_SNAKE_EYE),tp,LOCATION_MZONE,0,nil)
	return g:GetSum(Card.GetLevel)>=2
end
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(p,LOCATION_SZONE)
		and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden())
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsContinuousSpell()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (e:GetLabel()==1 and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.plfilter(chkc))
		or (e:GetLabel()==2 and chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp)) end
	local b1=Duel.IsExistingTarget(s.plfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.plfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
		if g:GetFirst():IsLocation(LOCATION_GRAVE) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
		end
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local op=e:GetLabel()
	if op==1 then
		--Place it face-up in its owner's Spell & Trap Zone as a Continuous Spell
		if tc:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
			Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
		elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
			--Treated as a Continuous Spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Special Summon it to your field
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end