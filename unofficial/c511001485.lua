--Tachyon Cannon
--時空殱滅砲
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(function(c) return c:IsTachyon() end))
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	--Secon attack in a row
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.atcon)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:GetAttack()>=500 and ec:IsRelateToBattle() and Duel.GetAttacker()==ec  and ec:CanChainAttack(0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if c:IsRelateToEffect(e) and ec:IsRelateToBattle() and not ec:IsImmuneToEffect(e) then
		local amt=ec:GetAttack()*(-0.5)
		if ec:UpdateAttack(amt,nil,c)==amt then
			Duel.ChainAttack()
		end
	end
end
