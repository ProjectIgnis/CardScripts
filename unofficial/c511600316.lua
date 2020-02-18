--必殺の間－Ａｉ－
--TA.I.med Technique
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)--+EFFECT_COUNT_CODE_OATH
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--End
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.bpcon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.bpop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetOperation(s.chk)
		Duel.RegisterEffect(e1,0)
	end
end
s.listed_series={0x135}
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	if s.condition() and Duel.GetFlagEffect(0,id)==0 then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_BATTLE,0,1)
		if Duel.GetAttacker():IsType(TYPE_LINK) and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsType(TYPE_LINK) then
			Duel.RegisterFlagEffect(0,id+1,RESET_PHASE+PHASE_BATTLE,0,1)
		end
	end
end
function s.condition()
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.filter1(c)
	return c:IsSetCard(0x135) and c:IsFaceup() and c:GetSequence()>4
end
function s.filter2(c)
	return c:IsType(TYPE_LINK) and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rc=g:GetFirst()
	if rc==exc then rc=g:GetNext() end
	if rc:IsRelateToEffect(e) and rc:IsAbleToRemove() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,rc:GetLink(),nil)
		if #rg>0 and Duel.Remove(rg+rc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
			local og=Duel.GetOperatedGroup()
			og:KeepAlive()
			for c in aux.Next(og) do
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1,e:GetFieldID())
			end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE)
			e1:SetLabelObject(og)
			e1:SetLabel(e:GetFieldID())
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
			if og:GetClassCount(Card.GetPreviousLocation)==2 and exc:IsRelateToEffect(e) then
				local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
				if zone>0 then
					Duel.MoveSequence(exc,math.log(2,zone))
				end
			end
		end
	end
end
function s.retfilter(c,e)
	return c:GetFlagEffectLabel(id)==e:GetLabel()
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():IsExists(s.retfilter,1,nil,e) then return true
	else e:SetLabelObject(nil) e:Reset() return false end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	for c in aux.Next(e:GetLabelObject():Filter(s.retfilter,nil,e)) do
		if c:GetPreviousLocation()==LOCATION_HAND then
			Duel.SendtoHand(c,c:GetPreviousControler(),REASON_RETURN)
		else
			Duel.ReturnToField(c)
		end
	end
	e:SetLabelObject(nil)
	e:Reset()
end
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return s.condition() and Duel.GetTurnPlayer()~=tp and Duel.GetFlagEffect(0,id+1)>0
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
end
