--ＳＲパッシングライダー (Manga)
--Speedroid Passinglider (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	--Must attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end