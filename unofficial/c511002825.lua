--パワー・ボンド (Anime)
--Power Bond (Anime)
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff{handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),stage2=s.stage2}
end
function s.stage2(e,tc,tp,sg,chk)
	if chk~=1 then return end
	local ogatk=tc:GetBaseAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(tc:GetAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(ogatk)
	e2:SetLabelObject(tc)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	Duel.RegisterEffect(e2,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffect(id)==0 then e:Reset() return false end
	return Duel.IsTurnPlayer(tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(e:GetLabelObject():GetControler(),e:GetLabel(),REASON_EFFECT)
end