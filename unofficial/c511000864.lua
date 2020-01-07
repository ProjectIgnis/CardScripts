--Emerging Awakening
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:GetLevel()>0 and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chk==0 then return tc and ep==tp and tc:IsFaceup() 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,tc) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,tc)
	local rc=g:GetFirst()
	if rc then
		Duel.HintSelection(g)
		if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e2:SetCountLimit(1)
			e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e2:SetLabelObject(rc)
			e2:SetOperation(s.spop)
			e2:SetLabel(Duel.GetTurnCount())
			Duel.RegisterEffect(e2,tp)
			Duel.Damage(1-tp,rc:GetLevel()*100,REASON_EFFECT)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,0)
		end
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetLabel() or not tc or tc:GetFlagEffect(id)==0 then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetLevel()*100)
		tc:RegisterEffect(e1)
	end
end
