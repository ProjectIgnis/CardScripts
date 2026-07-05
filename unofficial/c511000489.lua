--パワー・チャージャー
--Power Charger
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--If the equipped monster destroys an opponent's monster by battle, it gains ATK equal to that monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--During the End Phase, reduce the ATK gained by this effect to 0.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(e1)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return c:GetEquipTarget()==ec and bc:IsReason(REASON_BATTLE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local bc=ec:GetBattleTarget()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(bc:GetAttack())
	e1:SetLabelObject(e)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	ec:RegisterEffect(e1)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	if chk==0 then
		local effs={eqc:GetCardEffect(EFFECT_UPDATE_ATTACK)}
		for _,eff in ipairs(effs) do
			if eff:GetLabelObject()==e:GetLabelObject() then
				return true
			end
		end
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	local chk=false
	local effs={eqc:GetCardEffect(EFFECT_UPDATE_ATTACK)}
	for _,eff in ipairs(effs) do
		if eff:GetLabelObject()==e:GetLabelObject() then
			eff:Reset()
			chk=true
		end
	end
end
