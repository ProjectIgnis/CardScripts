--エクスカリバー
--Excalibur
--updated by ClaireStanfield & Larry126
local s,id=GetID()
function s.initial_effect(c)
aux.AddEquipProcedure(c)
	--double original atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Destroy on Draw
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--Skip Draw Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e3:SetOperation(s.dpop)
	c:RegisterEffect(e3)
end
function s.value(e,c)
	return c:GetBaseAttack()*2
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=e:GetHandler():GetControler() then return end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.dpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp and Duel.SelectYesNo(tp,aux.Stringid(51670553,0)) then
		Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_DRAW,1)
	end
end
