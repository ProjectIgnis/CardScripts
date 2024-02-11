--朔夜しぐれ
--Ghost Mourner & Moonlit Chill
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Negate effects of a Special Summoned monster and inflict damage if it leaves the field this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST|REASON_DISCARD)
end
function s.negfilter(c,p,eg)
	return c:IsSummonPlayer(p) and eg:IsContains(c) and (c:HasNonZeroAttack() or c:IsNegatableMonster())
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.negfilter(chkc,1-tp,eg) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,1-tp,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,1-tp,eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsNegatableMonster() then
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
		if tc:IsFaceup() then
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT|RESET_MSCHANGE|RESET_OVERLAY|RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetOperation(s.leaveop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if eg:IsContains(tc) and tc:GetFlagEffectLabel(id)==e:GetLabel() then
		local p=tc:GetPreviousControler()
		if Duel.Damage(p,tc:GetBaseAttack(),REASON_EFFECT)>0 then
			Duel.Hint(HINT_CARD,0,id)
		end
		tc:ResetFlagEffect(id)
		e:Reset()
	end
end