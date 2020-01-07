--Past Tuning
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={511003050}
function s.ccfilter(c,mc,oc,lv,tp)
	if c:IsFacedown() or not c:IsCode(511003050) then return false end
	mc:SetStatus(STATUS_NO_LEVEL,false)
	local e1=Effect.CreateEffect(mc)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_MONSTER)
	mc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(oc:GetRace())
	mc:RegisterEffect(e2,true)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(oc:GetAttribute())
	mc:RegisterEffect(e4,true)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_CHANGE_LEVEL)
	e6:SetValue(lv)
	mc:RegisterEffect(e6,true)
	local e8=e1:Clone()
	e8:SetCode(EFFECT_SET_ATTACK_FINAL)
	e8:SetValue(oc:GetAttack())
	mc:RegisterEffect(e8,true)
	local e10=e1:Clone()
	e10:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e10:SetValue(oc:GetDefense())
	mc:RegisterEffect(e10,true)
	local e11=Effect.CreateEffect(mc)
	e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_ADD_TYPE)
	e11:SetValue(TYPE_TUNER)
	c:RegisterEffect(e11,true)
	local e12=Effect.CreateEffect(mc)
	e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e12,true)
	local e13=e12:Clone()
	e13:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e13,true)
	tempchk=true
	local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,Group.FromCards(c,mc))
	tempchk=false
	e1:Reset()
	e2:Reset()
	e4:Reset()
	e6:Reset()
	e8:Reset()
	e10:Reset()
	e11:Reset()
	e12:Reset()
	e13:Reset()
	mc:SetStatus(STATUS_NO_LEVEL,true)
	return res
end
function s.ccfilter2(c)
	return c:IsFaceup() and c:IsCode(511003050)
end
function s.filter(c,mc,tp)
	local lv=c:GetLevel()
	local clv=0
	if lv>0 and lv<=4 then
		clv=1
	elseif lv>=5 and lv<=6 then
		clv=3
	else
		clv=5
	end
	return c:IsFaceup() and lv>0 and Duel.IsExistingMatchingCard(s.ccfilter,tp,LOCATION_MZONE,0,1,nil,mc,c,clv,tp)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.lvfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,c,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetLevel()
		local clv=0
		if lv>0 and lv<=4 then
			clv=1
		elseif lv>=5 and lv<=6 then
			clv=3
		else
			clv=5
		end
		if lv<=0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(clv)
		tc:RegisterEffect(e1)
		if tc:IsImmuneToEffect(e1) or not c:IsRelateToEffect(e) then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.ccfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tc,clv,tp)
		if #g<=0 then
			g=Duel.SelectMatchingCard(tp,s.ccfilter2,tp,LOCATION_MZONE,0,1,1,nil)
			if #g<=0 then return end
		end
		Duel.HintSelection(g)
		local cc=g:GetFirst()
		c:SetStatus(STATUS_NO_LEVEL,false)
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(tc:GetRace())
		c:RegisterEffect(e2)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(tc:GetAttribute())
		c:RegisterEffect(e4)
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CHANGE_LEVEL)
		e6:SetValue(clv)
		c:RegisterEffect(e6)
		local e8=e1:Clone()
		e8:SetCode(EFFECT_SET_ATTACK_FINAL)
		e8:SetValue(tc:GetAttack())
		c:RegisterEffect(e8)
		local e9=e8:Clone()
		cc:RegisterEffect(e9)
		local e10=e1:Clone()
		e10:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e10:SetValue(tc:GetDefense())
		c:RegisterEffect(e10)
		local e11=e1:Clone()
		e11:SetValue(TYPE_TUNER)
		cc:RegisterEffect(e11)
		local e12=Effect.CreateEffect(c)
		e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e12:SetType(EFFECT_TYPE_SINGLE)
		e12:SetCode(EFFECT_DISABLE)
		e12:SetReset(RESET_EVENT+RESETS_STANDARD)
		cc:RegisterEffect(e12)
		local e13=e12:Clone()
		e13:SetCode(EFFECT_DISABLE_EFFECT)
		cc:RegisterEffect(e13)
		local sg=Group.FromCards(c,cc)
		Duel.BreakEffect()
		local syng=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,sg)
		if #syng>0 then
			c:CancelToGrave()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=syng:Select(tp,1,1,nil):GetFirst()
			Duel.SynchroSummon(tp,sc,nil,sg)
			local fid=c:GetFieldID()
			sc:RegisterFlagEffect(51103052,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e16=Effect.CreateEffect(e:GetHandler())
			e16:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e16:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e16:SetCode(EVENT_PHASE+PHASE_END)
			e16:SetCountLimit(1)
			e16:SetLabel(fid)
			e16:SetLabelObject(sc)
			e16:SetCondition(s.descon)
			e16:SetOperation(s.desop)
			e16:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e16,tp)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(51103052)==e:GetLabel() then
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
