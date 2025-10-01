--ザ☆バトルバンプ
--The Battle Bump
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	c:RegisterEffect(e1)
	--Opponent cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsEquipSpell()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local dt=nil
	if ec==Duel.GetAttacker() then dt=Duel.GetAttackTarget()
	elseif ec==Duel.GetAttackTarget() then dt=Duel.GetAttacker() end
	e:SetLabelObject(dt)
	return dt and dt:IsRelateToBattle()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() and dt:IsDefensePos() then
		Duel.ChangePosition(dt,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end