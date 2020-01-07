--Gladiator Beast Assault Fort
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--name
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.gbtg)
	e3:SetValue(id+1)
	--c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_TYPE)
	e4:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	--c:RegisterEffect(e4)
	--negate
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.discon)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
	--activate
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetTarget(s.actg)
	e6:SetOperation(s.acop)
	c:RegisterEffect(e6)
	--
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(id+1)
	c:RegisterEffect(e7)
end
s.listed_series={0x19}
s.listed_names={id+1,511002975}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ep==tp and (a:IsSetCard(0x19) or (d and d:IsSetCard(0x19)))
end
function s.desfilter(c)
	return not c:IsSetCard(0x19) or c:IsFacedown()
end
function s.filter(c,tid)
	--if not c:IsCode(id+1) or c:GetFlagEffect(id)>0 then return false end
	if c:GetFlagEffect(id)>0 then return false end
	if c:IsHasEffect(id+1) and c:GetFieldID()<=tid then return false end
	--return not c:IsHasEffect(id+1) or c:GetFieldID()>tid
	return c:IsFaceup() and c:IsSetCard(0x19)
end
function s.ovfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_MONSTER)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
	if g then
		Duel.Destroy(g,REASON_EFFECT)
	end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,0,e:GetHandler(),e:GetHandler():GetFieldID())
	if not sg or #sg<=0 then return end
	local tc=sg:GetFirst()
	while tc do
		local cid=tc:ReplaceEffect(id+1,RESET_EVENT+RESETS_STANDARD)
		--reset
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_SZONE)
		e1:SetLabel(cid)
		e1:SetOperation(s.resetop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local og=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #og>0 then
			Duel.Overlay(tc,og)
		end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.effcon)
		e1:SetValue(id+1)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_TYPE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e2:SetCondition(s.effcon)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
end
function s.effcon(e)
	if e:GetHandler():GetFlagEffect(id)>0 and e:GetHandler():GetSequence()<5 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.gbtg(e,c)
	if not c:IsSetCard(0x19) or c==e:GetHandler() or c:GetSequence()>=5 then return false end
	return not c:IsHasEffect(id+1) or c:GetFieldID()>e:GetHandler():GetFieldID()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled()
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil) then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(id)
		e:Reset()
		if c:GetType()&TYPE_CONTINUOUS+TYPE_FIELD==0 then
			Duel.SendtoGrave(c,REASON_RULE)
		elseif not c:IsCode(id+1) then
			local og=c:GetOverlayGroup()
			if #og>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
		end
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsControler(tp) and re:GetHandler():IsCode(id+1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	re:GetHandler():CancelToGrave()
end
function s.acfilter(c,tp)
	local te=c:GetActivateEffect()
	return c:IsCode(511002975) and te:IsActivatable(tp)
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or g:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)>0) 
		and Duel.IsExistingMatchingCard(s.acfilter,tp,0x13,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.acfilter),tp,0x13,0,1,1,nil,tp):GetFirst()
		if tc then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			if (tpe&TYPE_FIELD)~=0 then
				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
				if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
					if fc then Duel.Destroy(fc,REASON_RULE) end
					fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				else
					Duel.GetFieldCard(tp,LOCATION_SZONE,5)
					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
				end
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
				tc:CancelToGrave(false)
			end
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if g then
				local etc=g:GetFirst()
				while etc do
					etc:CreateEffectRelation(te)
					etc=g:GetNext()
				end
			end
			if op then op(te,tp,eg,ep,ev,re,r,rp) end
			tc:ReleaseEffectRelation(te)
			if etc then	
				etc=g:GetFirst()
				while etc do
					etc:ReleaseEffectRelation(te)
					etc=g:GetNext()
				end
			end
		end
	end
end
