--魔導槍グレイス・スピア
--Magical Lance - Grace Spear
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,nil,nil,s.gainop)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER|RACE_MAGICALKNIGHT) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetTarget(s.eftg)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.value(e,c)
	local atk=0
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsRace(RACE_MAGICALKNIGHT) then atk=ec:GetLevel()*200 end
	return atk+200
end