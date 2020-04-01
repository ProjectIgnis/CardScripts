--鋼核収納
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x1d))
	--atk down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--destroy sub
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.desreptg)
	c:RegisterEffect(e4)
end
s.listed_series={0x1d}
function s.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler():GetEquipTarget():GetBattleTarget()
end
function s.atktg(e,c)
	return c==e:GetHandler():GetEquipTarget():GetBattleTarget()
end
function s.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetLevel()*-100
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:GetEquipTarget():IsReason(REASON_REPLACE) and Duel.GetCurrentPhase()==PHASE_END end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return true
	else return false end
end
