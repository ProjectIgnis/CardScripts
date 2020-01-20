--銀河眼の光子竜
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.rfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
function s.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	return ft>-2 and #rg>1 and (ft>0 or rg:IsExists(s.mzfilter,ct,nil,tp))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=nil
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		g=rg:FilterSelect(tp,s.mzfilter,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		g=rg:FilterSelect(tp,s.mzfilter,2,2,nil,tp)
	end
	Duel.Release(g,REASON_COST)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsOnField() and bc:IsCanBeEffectTarget(e) and c:IsAbleToRemove() and bc:IsAbleToRemove() end
	Duel.SetTargetCard(bc)
	local g=Group.FromCards(c,bc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	local mcount=0
	if tc:IsFaceup() then mcount=tc:GetOverlayCount() end
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		if not og:IsContains(tc) then mcount=0 end
		local oc=og:GetFirst()
		for oc in aux.Next(og) do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		e1:SetLabel(mcount)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	g:DeleteGroup()
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		if Duel.ReturnToField(tc) and tc==e:GetOwner() and tc:IsFaceup() and e:GetLabel()~=0 then
			local e1=Effect.CreateEffect(e:GetOwner())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			e1:SetValue(e:GetLabel()*500)
			e:GetOwner():RegisterEffect(e1)
		end
	end
end
