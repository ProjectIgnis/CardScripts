--Future Battle
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	--Battle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return s.tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if s.con(e,tp,eg,ep,ev,re,r,rp) and s.tg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(61965407,0)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.op)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		s.tg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and Duel.GetTurnPlayer()==tp
end
function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:CanAttack()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.IsPlayerCanSpecialSummon(tp) and tc and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and (not tc:IsPublic() or tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)) 
		and e:GetHandler():GetFlagEffect(id)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	if tc:IsPublic() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.DisableShuffleCheck()
		Duel.ConfirmDecktop(1-tp,1)
		local g=Duel.GetDecktopGroup(1-tp,1)
		local rc=g:GetFirst()
		if rc:IsType(TYPE_MONSTER) then
			if rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
				and Duel.SpecialSummon(rc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)>0 then
				local fid=c:GetFieldID()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_MUST_ATTACK)
				e1:SetCondition(s.atkcon)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(rc)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
				tc:RegisterEffect(e2)
				tc:RegisterFlagEffect(51100782,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				local e3=e2:Clone()
				e3:SetCondition(aux.TRUE)
				e3:SetCode(EFFECT_MUST_BE_ATTACKED)
				e3:SetValue(s.atkval)
				e3:SetLabel(fid)
				e3:SetLabelObject(tc)
				rc:RegisterEffect(e3)
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e4:SetCode(EVENT_LEAVE_FIELD)
				e4:SetOperation(s.regop)
				e4:SetLabel(fid)
				e4:SetLabelObject(e)
				rc:RegisterEffect(e4,true)
				rc:RegisterFlagEffect(51100783,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			end
		else
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
function s.atkcon(e)
	local tc=e:GetLabelObject()
	return tc and tc:GetFlagEffectLabel(51100783)==e:GetLabel()
end
function s.atkval(e,c)
	return not c:IsImmuneToEffect(e) and c==e:GetLabelObject() and c:GetFlagEffectLabel(51100782)==e:GetLabel()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) and c:GetReasonCard() and c:GetReasonCard():GetFlagEffectLabel(51100782)==e:GetLabel() then
		if e:GetLabelObject():GetLabel()~=1 then
			e:GetLabelObject():SetCountLimit(1)
		end
		e:GetOwner():ResetFlagEffect(id)
	end
	e:Reset()
end
