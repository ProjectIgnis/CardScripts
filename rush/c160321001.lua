--キメラテック・オーバー・ドラゴン
--Chimeratech Overdragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),1,99,CARD_CYBER_DRAGON)
	--spsummon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.sucop)
	c:RegisterEffect(e1)
end
s.material_setcode={SET_CYBER,SET_CYBER_DRAGON}
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*800)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(c:GetMaterialCount()-1)
	c:RegisterEffect(e3)
end
