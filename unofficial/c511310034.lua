--ゾンビプロセイバー
--Zombie Prosaber
--Scripted by AlphaKretin, fixed by Larry126
local s,id = GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsType(TYPE_NORMAL,lc,sumtype,tp) and c:IsRace(RACE_CYBERSE,lc,sumtype,tp)
end
function s.spfilter(c,e,tp)
	local zone=2^(c:GetPreviousSequence())
	local p=c:GetPreviousControler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY)
		and (e:GetHandler():GetLinkedZone(p)&zone)==zone and p==1-tp
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsControler(1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.spfilter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local c=e:GetHandler()
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tc:CompleteProcedure()
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.descon)
		e2:SetOperation(s.desop)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end