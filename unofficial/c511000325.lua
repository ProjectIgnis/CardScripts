--Mecha Ojama King
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.splimit(e,se,sp,st)
	return st==(SUMMON_TYPE_SPECIAL+511000324)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local con1=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>2
	local con2=Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp)
	local con3=Duel.GetLocationCount(tp,LOCATION_MZONE,tp)>2
	local con4=Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,tp)
	if chk==0 then return (con1 and con2) or (con3 and con4) end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	if (con1 and con2) and (con3 and con4) then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,2))
	elseif (con3 and con4) then
		Duel.SelectOption(tp,aux.Stringid(id,3))
		op=0
	else
		Duel.SelectOption(tp,aux.Stringid(id,2))
		op=1
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,tp)<3 then return end
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,tp) then return end
		for i=1,3 do
			local token=Duel.CreateToken(tp,29843091+i)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_DESTROY)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetOperation(s.damop2)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e2,true)
			end
		end
		Duel.SpecialSummonComplete()
	else
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<3 then return end
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,29843092,0xf,TYPES_TOKEN,0,1000,2,RACE_BEAST,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
		for i=1,3 do
			local token=Duel.CreateToken(tp,29843091+i)
			if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(1)
				token:RegisterEffect(e1,true)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_DESTROY)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetOperation(s.damop)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e2,true)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				token:RegisterEffect(e3,true)
			end
		end
		Duel.SpecialSummonComplete()
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,500,REASON_EFFECT)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
