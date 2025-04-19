--マーカーズ・ポータル
--Marker's Portal
--Scripted by the Razgriz & Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
	aux.GlobalCheck(s,function()
		Duel.RegisterFlagEffect(0,id+100,0,0,0,Duel.GetLP(0))
		Duel.RegisterFlagEffect(1,id+100,0,0,0,Duel.GetLP(1))
	end)
end
function s.filter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSpell() and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLP(tp)<Duel.GetFlagEffectLabel(tp,id+100)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--opd register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Check if Skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Activates
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		if tc:IsType(TYPE_FIELD) then
			Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
		else
			local zone=0xff
			local te=tc:GetActivateEffect()
			if te and te:GetValue() then
				local val=te:GetValue()
				if type(val)=="number" then zone=val
				else zone=val(e,tp,eg,ep,ev,re,r,rp) end
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(s.efilter)
		tc:RegisterEffect(e2,true)
	end
end
function s.efilter(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end