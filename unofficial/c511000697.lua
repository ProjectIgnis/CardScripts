-- 王者の聖外套
--Emperor's Armor
local s,id=GetID()
function s.initial_effect(c)
	--Equip procedure
	aux.AddEquipProcedure(c)
	--Equipped monster's ATK becomes battling monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Send this card to the GY to prevent battle destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	local ac=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
	return ec and ac~=nil and dc~=nil and (ac==ec or dc==ec)
end
function s.atkval(e,c)
	local eq=e:GetHandler():GetEquipTarget()
	return eq:GetBattleTarget():GetAttack()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return c and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and ec and ec:IsReason(REASON_BATTLE) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoGrave(c,REASON_EFFECT|REASON_REPLACE)
	if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
		if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local ec=c:GetPreviousEquipTarget()
			local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			local atk1=ec:GetAttack()
			local atk2=tc:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk2)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			ec:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK)
			e2:SetValue(atk1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_EXTRA_ATTACK)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
			ec:RegisterEffect(e3)
		end
	end
end