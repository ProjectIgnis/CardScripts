--Rotation Blade of Pioneer
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Atk,def
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsType(TYPE_SYNCHRO)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget():GetMaterialCount()
	if chk==0 then return ec>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ec*400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=e:GetHandler():GetEquipTarget():GetMaterialCount()*400
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
