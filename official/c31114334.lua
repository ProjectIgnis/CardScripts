--Ａ ＢＦ－叢雲のクサナギ
--Assault Blackwing - Kusanagi the Gathering Storm
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(function(e,c) e:SetLabel(c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_BLACKWING) and 1 or 0) end)
	c:RegisterEffect(e0)
	--If this card is Synchro Summoned using a "Blackwing" monster as material, it is treated as a Tuner while face-up on the field. After this card is Synchro Summoned, for the rest of this turn, it gains ATK equal to the total original ATK of the Synchro Monsters used as its material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetLabelObject(e0)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Can attack all your opponent's monsters, once each
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--If this card attacks a Defense Position monster, nflict piercing battle damage to your opponent
	local e3=e2:Clone()
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BLACKWING}
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if #mg==0 then return end
	if e:GetLabelObject():GetLabel()==1 then
		--If this card is Synchro Summoned using a "Blackwing" monster as material, it is treated as a Tuner while face-up on the field
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if c:IsDisabled() then return end
	local atk=mg:Match(Card.IsSynchroMonster,nil):GetSum(Card.GetBaseAttack,nil)
	if atk==0 then return end
	--After this card is Synchro Summoned, for the rest of this turn, it gains ATK equal to the total original ATK of the Synchro Monsters used as its material
	c:UpdateAttack(atk,RESETS_STANDARD_DISABLE_PHASE_END)
end
