--Ｈ・Ｄ・Ｄ
--H.D.D. - Hundred Divine Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prompt player if they want to draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<5 end)
	e1:SetOperation(s.predrop)
	c:RegisterEffect(e1)
end
function s.predrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Prevents activating Trap Card after the "initial Normal Draw"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)<6 end)
	e1:SetValue(function(_,re) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
	--Performs the Extra draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetCountLimit(1)
	e2:SetOperation(function(_,tp) Duel.Draw(tp,1,REASON_RULE) end)
	e2:SetReset(RESET_PHASE+PHASE_DRAW)
	Duel.RegisterEffect(e2,tp)
end