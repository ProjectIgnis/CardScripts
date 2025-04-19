--ドラゴンスレイヤー
--Dragonslayer
--Scripted by Snrk, updated by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Gain 1400 ATK when battling a Dragon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.condition)
	e1:SetValue(1400)
	c:RegisterEffect(e1)
end
function s.condition(e)
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	return bc and bc:IsFaceup() and bc:IsRace(RACE_DRAGON)
end