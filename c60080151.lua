--好敵手の記憶
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsOnField() and tc:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,tc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:CanAttack() and tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		local dam=tc:GetAttack()
		if Duel.Damage(tp,dam,REASON_EFFECT)>0 and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCountLimit(1)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCondition(s.spcon)
			e1:SetOperation(s.spop)
			e1:SetLabelObject(tc)
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			Duel.RegisterEffect(e1,tp)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()~=tp
		and tc:GetFlagEffect(id)~=0 and tc:GetReasonEffect():GetHandler()==e:GetHandler()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.SpecialSummon(e:GetLabelObject(),0,tp,tp,false,false,POS_FACEUP)
end
