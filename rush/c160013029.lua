--石膏の斥候
--Plaster Scout
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--No effect damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
end
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if (r&REASON_EFFECT)~=0 and rp~=e:GetOwnerPlayer() and Duel.IsTurnPlayer(1-tp) and Duel.GetCurrentPhase()==PHASE_MAIN1 then return 0
	else return val end
end