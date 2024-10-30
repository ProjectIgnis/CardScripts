--セカンド・チャンス
--Second Coin Toss
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Redo your coin toss
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.coincon)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and not Duel.HasFlagEffect(tp,id)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.TossCoin(tp,ev)
	end
end