--RR Target Flag
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,1,nil,CATEGORY_DRAW,nil,TIMING_STANDBY_PHASE,0x1c0,nil,nil,s.target,s.operation,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		local td=Duel.GetDecktopGroup(tp,1):GetFirst()
		if td then
			Duel.Draw(tp,1,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,td)
			local desc
			local label
			if td:IsType(TYPE_MONSTER) then
				label=TYPE_MONSTER
				desc=70
			elseif td:IsType(TYPE_SPELL) then
				label=TYPE_SPELL
				desc=71
			else
				label=TYPE_TRAP
				desc=72
			end
			Duel.ShuffleHand(tp)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(desc)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCategory(CATEGORY_DESTROY)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_DELAY)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetCondition(s.descon)
			e2:SetTarget(s.destg)
			e2:SetOperation(s.desop)
			e2:SetLabel(label)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 then
		if e:GetLabel()==0 then return end
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		Duel.ConfirmCards(tp,hg)
		local dg=hg:Filter(Card.IsType,nil,e:GetLabel())
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
	e:SetDescription(0)
end
