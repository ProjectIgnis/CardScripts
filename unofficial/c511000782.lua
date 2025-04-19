--フューチャー・バトル
--Future Battle
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Battle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and not Duel.GetAttacker() and Duel.IsTurnPlayer(tp)
end
function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:CanAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.IsPlayerCanSpecialSummon(tp) and tc and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and (not tc:IsPublic() or tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if tc:IsPublic() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.DisableShuffleCheck()
		Duel.ConfirmDecktop(1-tp,1)
		local rc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
		if rc and rc:IsMonster() then
			if rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
				and Duel.SpecialSummon(rc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)>0 then
				local fid=c:GetFieldID()
				tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1,fid)
				rc:RegisterFlagEffect(id+100,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1,fid)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_MUST_ATTACK)
				e1:SetCondition(s.atkcon)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetLabelObject(rc)
				e1:SetLabel(fid)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
				e2:SetValue(s.atkval)
				tc:RegisterEffect(e2)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_FIRST_ATTACK)
				tc:RegisterEffect(e3)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
				e4:SetCondition(s.exatkcon)
				e4:SetValue(1)
				tc:RegisterEffect(e4)
				local e5=Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e5:SetCode(EVENT_LEAVE_FIELD)
				e5:SetOperation(s.regop)
				e5:SetLabel(fid)
				e5:SetLabelObject(e)
				e5:SetReset(RESET_PHASE+PHASE_END)
				rc:RegisterEffect(e5,true)
			end
		else
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
function s.atkcon(e)
	local tc=e:GetLabelObject()
	return tc and tc:GetFlagEffectLabel(id+100)==e:GetLabel()
end
function s.exatkcon(e)
	local tc=e:GetLabelObject()
	return tc and e:GetHandler():GetAttackedGroup():IsContains(tc)
end
function s.atkval(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffectLabel(id+100)==e:GetLabel()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) and c:GetReasonCard() and c:GetReasonCard():GetFlagEffectLabel(id)==e:GetLabel() then
		e:GetLabelObject():SetCountLimit(1)
	end
	e:Reset()
end