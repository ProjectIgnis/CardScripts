-- Mind Scan
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(1)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
		if e:GetLabel()==0 then
			local c=e:GetHandler()
			local coverid = Auxiliary.GetCover(c,e:GetLabel())
			if e:GetLabel()>0 then
				Duel.Hint(HINT_SKILL_COVER,c:GetControler(),coverid|(coverid<<32))
				Duel.Hint(HINT_SKILL,c:GetControler(),c:GetCode())			
				Duel.SendtoDeck(c,tp,-2,REASON_RULE)
				if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
					Duel.Draw(p,1,REASON_RULE)
				end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PREDRAW)
				e1:SetCondition(s.flipcon)
				e1:SetOperation(s.flipop)
				Duel.RegisterEffect(e1,tp)
			end
			e:SetLabel(0)
		end
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==3 and Duel.GetLP(tp)>=3000
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--ask if you want to activate the skill or not
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end 
	
	Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	--look at hand
	local g=Duel.GetFieldGroup(1-tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			--skill is active flag
			Duel.RegisterFlagEffect(tp,id,0,0,0)
			--mind scan
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ADJUST)
			e1:SetCondition(s.con1)
			e1:SetOperation(s.op1)
			Duel.RegisterEffect(e1,tp)
			--flip back if LP<3000
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_ADJUST)
			e2:SetCondition(s.con2)
			e2:SetOperation(s.op2)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)~=0
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
		if tc:GetFlagEffect(id)==0 then
			Duel.ConfirmCards(tp,tc)
			tc:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
		end
		tc=g:GetNext()
		end	
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)~=0 and Duel.GetLP(tp)<3000
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(2<<32))
	Duel.ResetFlagEffect(tp, id)
end
