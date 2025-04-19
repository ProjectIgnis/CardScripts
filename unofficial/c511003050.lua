--ＣＣ 隻眼のパスト・アイ
--C/C Critical Eye
local s,id=GetID()
cetempchk=false --Critical Eye temp check, handling C/C Spells that negate Critical Eye
function s.initial_effect(c)
	--Fusion, synchro, and Xyz material limitations
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_MAT_RESTRICTION)
	e1:SetCondition(function(e) return not cetempchk end)
	e1:SetValue(s.filter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_XYZ_MAT_RESTRICTION)
	c:RegisterEffect(e3)
end
function s.filter(e,c)
	return not c:IsControler(e:GetHandlerPlayer())
end