--Gladiator Beast Great Fortress
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--re-place
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.ovtg)
	e4:SetOperation(s.ovop)
	e4:SetCountLimit(1)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_MONSTER)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(12744567,0)) then
		Duel.Overlay(c,sg)
		local g=Duel.GetMatchingGroup(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
			end
			tc=g:GetNext()
		end
	end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=c:GetOverlayGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local chk=51102975
		while c:GetFlagEffect(chk)>0 do
			chk=chk+1
		end
		tc:RegisterFlagEffect(51102975,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1,chk)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		local at=Duel.GetAttacker()
		if at:CanAttack() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
			local atk=c:GetOverlayCount()*1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
			e1:SetValue(1000+atk)
			tc:RegisterEffect(e1)
			Duel.CalculateDamage(at,tc)
		end
		c:RegisterFlagEffect(chk,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
function s.damfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE) 
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:GetOwner()==tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct1=eg:FilterCount(s.damfilter,nil,tp)
	local ct2=eg:FilterCount(s.damfilter,nil,1-tp)
	Duel.Damage(tp,ct1*500,REASON_EFFECT)
	Duel.Damage(1-tp,ct2*500,REASON_EFFECT)
end
function s.ovfilter(c,fid)
	return c:GetFlagEffectLabel(51102975)==fid
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=51102975
	while e:GetHandler():GetFlagEffect(check)==0 do
		check=check+1
		if check>=51103000 then return false end
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil,check) end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local chk=51102975
	while c:GetFlagEffect(chk)==0 do
		chk=chk+1
		if chk>=51103000 then return end
	end
	local g=Duel.GetMatchingGroup(s.ovfilter,tp,LOCATION_MZONE,0,nil,chk)
	Duel.Overlay(c,g)
end
