--モノ・シンクロン
local s,id=GetID()
function s.initial_effect(c)
	--synchro custom
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	e4:SetValue(s.synfilter)
	c:RegisterEffect(e4)
end
function s.synfilter(e,c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR+RACE_MACHINE)
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	return #sg-1+e:GetHandler():GetLevel()==lv,true
end
