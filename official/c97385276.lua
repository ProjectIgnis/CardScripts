--レベル・ウォリアー
--Level Warrior
local s,id=GetID()
function s.initial_effect(c)
	--If there are no monsters on the field, you can Normal Summon this card as a Level 2 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.nscon)
	e1:SetOperation(s.nsop)
	e1:SetValue(1)
	e1:SetLabelObject({function(c) c:AssumeProperty(ASSUME_LEVEL,2) end})
	c:RegisterEffect(e1)
	--If your opponent controls a monster and you control no monsters, you can Special Summon this card (from your hand) as a Level 4 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	e2:SetLabelObject({function(c) c:AssumeProperty(ASSUME_LEVEL,4) end})
	c:RegisterEffect(e2)
end
function s.nscon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(0,LOCATION_MZONE,LOCATION_MZONE)==0
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp,c)
	c:AssumeProperty(ASSUME_LEVEL,2)
	--Normal Summon this card as a Level 2 monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD_DISABLE&~RESET_TOFIELD))
	c:RegisterEffect(e1)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	c:AssumeProperty(ASSUME_LEVEL,4)
	--Special Summon this card (from your hand) as a Level 4 monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD_DISABLE&~RESET_TOFIELD))
	c:RegisterEffect(e1)
end