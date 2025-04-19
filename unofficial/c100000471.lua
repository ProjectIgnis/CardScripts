--瞬間融合
--Flash Fusion (anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat,nil,nil,nil,s.stage2)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:GetFlagEffect(id)>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end