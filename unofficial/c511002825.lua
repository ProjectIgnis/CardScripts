--パワー・ボンド (Anime)
--Power Bond (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),nil,nil,nil,nil,s.stage2))
end
function s.stage2(e,tc,tp,sg,chk)
	if chk~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(tc:GetAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	Duel.RegisterEffect(e2,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return false end
	return Duel.GetTurnPlayer()==tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then return end
	local tc=e:GetLabelObject():GetHandler()
	Duel.Damage(tc:GetControler(),tc:GetBaseAttack(),REASON_EFFECT)
end
