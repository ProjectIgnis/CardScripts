--Ｈ・Ｄ・Ｄ
--H.D.D. - Hundred Divine Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prompt player if they want to draw
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.drcon)
	e0:SetOperation(s.predrop)
	c:RegisterEffect(e0)
	--Performs the Extra draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_DRAW)
	e1:SetCondition(s.drcon2)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.predrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,0,1)
	--prevents activating Trap card after the "initial Normal Draw"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
end
function s.aclimit(e,re,tp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_TRAP))
end
function s.actcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)<6
end
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffect(id)>0
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_RULE)
end
