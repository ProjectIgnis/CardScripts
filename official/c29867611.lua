--Ａ・Ɐ・ＭＭ
--Amaze Attraction Majestic Merry-Go-Round
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--From cards_specific_functions.lua
	aux.AddAttractionEquipProc(c)
	--You: The equipped monster gains 500 ATK, also if it would be destroyed by battle or card effect, you can send this card to the GY instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Your opponent: The equipped monster loses 500 ATK for each of your "Ɐttraction" Traps that are equipped to a monster.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
end
s.listed_series={SET_AMAZEMENT,SET_ATTRACTION}
function s.atkfilter(c)
	return c:IsTrap() and c:IsSetCard(SET_ATTRACTION) and c:GetEquipTarget()
end
function s.atkval(e,c)
	local et=e:GetHandler():GetEquipTarget()
	local hp=e:GetHandlerPlayer()
	if not et then return 0 end
	if et:GetControler()==hp then
		return 500
	else
		return Duel.GetMatchingGroupCount(s.atkfilter,hp,LOCATION_SZONE,0,nil)*-500
	end
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return tc:IsControler(tp) and not tc:IsReason(REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return true
	else return false end
end